package com.atrio.pg.auth.service;

import com.atrio.pg.auth.domain.RefreshToken;
import com.atrio.pg.auth.dto.AuthTokensResponse;
import com.atrio.pg.auth.dto.OtpRequestResponse;
import com.atrio.pg.auth.dto.UpdateProfileRequest;
import com.atrio.pg.auth.repository.RefreshTokenRepository;
import com.atrio.pg.auth.security.AuthProperties;
import com.atrio.pg.auth.security.JwtService;
import com.atrio.pg.auth.security.RefreshTokenHasher;
import com.atrio.pg.common.exception.ApiException;
import com.atrio.pg.common.exception.ErrorCode;
import com.atrio.pg.users.domain.User;
import com.atrio.pg.users.domain.UserRole;
import com.atrio.pg.users.dto.UserResponse;
import com.atrio.pg.users.repository.UserRepository;
import java.time.Duration;
import java.time.Instant;
import java.util.Locale;
import java.util.Optional;
import java.util.UUID;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * The whole auth flow: phone OTP login, token issuance, refresh rotation,
 * logout, and profile completion.
 *
 * <p>All of it lives here rather than in the controller, per CLAUDE.md 3.13.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final OtpService otpService;
    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final RefreshTokenFamilyRevoker familyRevoker;
    private final RefreshTokenHasher refreshTokenHasher;
    private final JwtService jwtService;
    private final AuthProperties properties;

    /** Step 1 of login: send a code. Rate limited per phone. */
    public OtpRequestResponse requestOtp(String phone) {
        Duration ttl = otpService.issue(phone, Instant.now());
        return new OtpRequestResponse(phone, ttl.toSeconds());
    }

    /**
     * Step 2 of login: check the code, create the account if this phone is new,
     * and issue a token pair.
     *
     * <p>Transactional as a unit so a failure cannot consume the code without
     * issuing tokens, which would strand the user needing a fresh code.
     */
    @Transactional
    public AuthTokensResponse verifyOtp(String phone, String code) {
        Instant now = Instant.now();
        otpService.verify(phone, code, now);

        Optional<User> existing = userRepository.findByPhone(phone);
        boolean isNewUser = existing.isEmpty();
        User user = existing.orElseGet(() -> createUser(phone));

        if (!user.isActive()) {
            throw new ApiException(
                    ErrorCode.ACCOUNT_DISABLED, "This account has been disabled.");
        }

        user.setLastLoginAt(now);
        userRepository.save(user);

        return issueTokens(user, now, isNewUser);
    }

    /**
     * Rotates a refresh token (MIGRATION_PLAN.md 6.3).
     *
     * <p>Rotation is append-style, per CLAUDE.md 3.5: the presented row is
     * revoked and a new row inserted, never updated in place, so the chain
     * stays auditable.
     *
     * <p>Presenting an already-revoked token means it leaked - the legitimate
     * client would have moved on to its successor. Every live token for that
     * user is revoked and {@code REFRESH_TOKEN_REUSED} is returned.
     */
    @Transactional
    public AuthTokensResponse refresh(String presentedToken) {
        Instant now = Instant.now();
        String hash = refreshTokenHasher.hash(presentedToken);

        RefreshToken stored = refreshTokenRepository.findByTokenHash(hash)
                .orElseThrow(AuthService::invalidRefreshToken);

        if (stored.isRevoked()) {
            familyRevoker.revokeAllForUser(stored.getUserId(), now);
            throw new ApiException(
                    ErrorCode.REFRESH_TOKEN_REUSED,
                    "This session was ended for security reasons. Please sign in again.");
        }
        if (!stored.getExpiresAt().isAfter(now)) {
            throw invalidRefreshToken();
        }

        User user = userRepository.findById(stored.getUserId())
                .orElseThrow(AuthService::invalidRefreshToken);
        if (!user.isActive()) {
            throw new ApiException(
                    ErrorCode.ACCOUNT_DISABLED, "This account has been disabled.");
        }

        stored.setRevokedAt(now);
        refreshTokenRepository.save(stored);

        return issueTokens(user, now, false);
    }

    /**
     * Revokes the presented refresh token.
     *
     * <p>Only if it actually belongs to the caller - otherwise a signed-in user
     * could revoke someone else's session by guessing. Either way the response
     * is the same, so nothing is leaked about which tokens exist.
     */
    @Transactional
    public void logout(UUID callerId, String presentedToken) {
        Instant now = Instant.now();
        refreshTokenRepository.findByTokenHash(refreshTokenHasher.hash(presentedToken))
                .filter(token -> token.getUserId().equals(callerId))
                .filter(token -> !token.isRevoked())
                .ifPresent(token -> {
                    token.setRevokedAt(now);
                    refreshTokenRepository.save(token);
                });
    }

    /**
     * Completes or edits the profile.
     *
     * <p>Role is the interesting part: it may be set once and only once
     * (CLAUDE.md 6), which is enforceable because
     * {@code V2__role_settable_once.sql} added {@code role_chosen_at} and
     * removed the {@code 'student'} column default that used to make every new
     * account look like a deliberate choice.
     */
    @Transactional
    public UserResponse updateProfile(UUID userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> ApiException.notFound("Account not found."));

        if (request.name() != null) {
            user.setName(request.name().trim());
        }
        if (request.gender() != null) {
            user.setGender(request.gender());
        }
        if (request.email() != null) {
            user.setEmail(normalizeEmail(user, request.email()));
        }
        if (request.role() != null) {
            applyRole(user, request.role());
        }

        return UserResponse.from(userRepository.save(user));
    }

    @Transactional(readOnly = true)
    public UserResponse currentUser(UUID userId) {
        return userRepository.findById(userId)
                .map(UserResponse::from)
                .orElseThrow(() -> ApiException.notFound("Account not found."));
    }

    // ---- internals ---------------------------------------------------

    private User createUser(String phone) {
        User user = new User();
        user.setPhone(phone);
        // Provisional, not a choice: roleChosenAt stays null until the user
        // picks one on the profile screen. The column default that used to
        // supply this was dropped in V2 precisely so it is stated here.
        user.setRole(UserRole.STUDENT);
        user.setActive(true);
        log.info("Creating account for {}", phone);
        return userRepository.save(user);
    }

    private void applyRole(User user, UserRole requested) {
        if (requested == UserRole.ADMIN) {
            throw ApiException.forbidden("Role 'admin' cannot be self-assigned.");
        }
        if (user.canChooseRole()) {
            user.setRole(requested);
            user.setRoleChosenAt(Instant.now());
            return;
        }
        // Re-sending the same role is a no-op, so a client retry after a
        // dropped response does not fail.
        if (user.getRole() != requested) {
            throw new ApiException(
                    ErrorCode.ROLE_ALREADY_SET,
                    "Your role has already been set and cannot be changed.");
        }
    }

    /**
     * {@code uq_users_email} is on {@code lower(email)}, so the value must be
     * lowercased on write and on lookup or the index rejects something the
     * application believed was new (MIGRATION_PLAN.md 8.8).
     */
    private String normalizeEmail(User user, String email) {
        String normalized = email.trim().toLowerCase(Locale.ROOT);
        if (normalized.isEmpty()) {
            return null;
        }
        userRepository.findByEmail(normalized)
                .filter(other -> !other.getId().equals(user.getId()))
                .ifPresent(other -> {
                    throw new ApiException(
                            ErrorCode.EMAIL_TAKEN, "That email is already in use.");
                });
        return normalized;
    }

    private AuthTokensResponse issueTokens(User user, Instant now, boolean isNewUser) {
        String accessToken = jwtService.issueAccessToken(user, now);
        String refreshToken = refreshTokenHasher.newToken();

        RefreshToken entity = new RefreshToken();
        entity.setUserId(user.getId());
        entity.setTokenHash(refreshTokenHasher.hash(refreshToken));
        entity.setExpiresAt(now.plus(properties.jwt().refreshTtl()));
        refreshTokenRepository.save(entity);

        return new AuthTokensResponse(
                accessToken, refreshToken, UserResponse.from(user), isNewUser);
    }

    private static ApiException invalidRefreshToken() {
        return new ApiException(
                ErrorCode.REFRESH_TOKEN_INVALID, "Your session has expired. Please sign in again.");
    }
}
