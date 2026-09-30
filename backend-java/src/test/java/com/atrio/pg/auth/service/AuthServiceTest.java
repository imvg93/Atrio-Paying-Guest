package com.atrio.pg.auth.service;

import static com.atrio.pg.support.AuthTestFixtures.properties;
import static com.atrio.pg.support.AuthTestFixtures.user;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import com.atrio.pg.auth.domain.RefreshToken;
import com.atrio.pg.auth.dto.AuthTokensResponse;
import com.atrio.pg.auth.dto.UpdateProfileRequest;
import com.atrio.pg.auth.repository.RefreshTokenRepository;
import com.atrio.pg.auth.security.JwtService;
import com.atrio.pg.auth.security.RefreshTokenHasher;
import com.atrio.pg.common.exception.ApiException;
import com.atrio.pg.common.exception.ErrorCode;
import com.atrio.pg.users.domain.Gender;
import com.atrio.pg.users.domain.User;
import com.atrio.pg.users.domain.UserRole;
import com.atrio.pg.users.dto.UserResponse;
import com.atrio.pg.users.repository.UserRepository;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mockito.junit.jupiter.MockitoSettings;
import org.mockito.quality.Strictness;

@ExtendWith(MockitoExtension.class)
@MockitoSettings(strictness = Strictness.LENIENT)
class AuthServiceTest {

    private static final String PHONE = "+919876543210";

    @Mock private OtpService otpService;
    @Mock private UserRepository userRepository;
    @Mock private RefreshTokenRepository refreshTokenRepository;
    @Mock private RefreshTokenFamilyRevoker familyRevoker;

    private RefreshTokenHasher hasher;
    private AuthService service;

    @BeforeEach
    void setUp() {
        hasher = new RefreshTokenHasher(properties());
        service = new AuthService(
                otpService, userRepository, refreshTokenRepository, familyRevoker,
                hasher, new JwtService(properties()), properties());

        // Stand in for Hibernate's @UuidGenerator, which assigns the id on
        // persist. Without it a newly created user has a null id and the
        // token's `sub` claim would blow up in a way production never does.
        when(userRepository.save(any(User.class))).thenAnswer(inv -> {
            User saved = inv.getArgument(0);
            if (saved.getId() == null) {
                saved.setId(UUID.randomUUID());
            }
            return saved;
        });
        when(refreshTokenRepository.save(any(RefreshToken.class)))
                .thenAnswer(inv -> inv.getArgument(0));
    }

    private RefreshToken storedToken(UUID userId, String rawToken, Instant expiresAt) {
        RefreshToken token = new RefreshToken();
        token.setId(UUID.randomUUID());
        token.setUserId(userId);
        token.setTokenHash(hasher.hash(rawToken));
        token.setExpiresAt(expiresAt);
        return token;
    }

    // ---- verify ------------------------------------------------------

    @Test
    @DisplayName("an unknown phone creates an account flagged isNewUser")
    void verifyCreatesAccount() {
        when(userRepository.findByPhone(PHONE)).thenReturn(Optional.empty());

        AuthTokensResponse response = service.verifyOtp(PHONE, "123456");

        assertThat(response.isNewUser()).isTrue();
        assertThat(response.user().role()).isEqualTo(UserRole.STUDENT);
        assertThat(response.user().roleLocked())
                .as("a provisional student has not chosen anything yet")
                .isFalse();
        assertThat(response.accessToken()).isNotBlank();
        assertThat(response.refreshToken()).isNotBlank();
    }

    @Test
    @DisplayName("a known phone signs in without isNewUser and stamps last_login_at")
    void verifyReturningUser() {
        User existing = user(PHONE, UserRole.OWNER);
        when(userRepository.findByPhone(PHONE)).thenReturn(Optional.of(existing));

        AuthTokensResponse response = service.verifyOtp(PHONE, "123456");

        assertThat(response.isNewUser()).isFalse();
        assertThat(response.user().role()).isEqualTo(UserRole.OWNER);
        assertThat(existing.getLastLoginAt()).isNotNull();
    }

    @Test
    @DisplayName("a disabled account cannot sign in even with a valid code")
    void verifyDisabledAccount() {
        User disabled = user(PHONE, UserRole.STUDENT);
        disabled.setActive(false);
        when(userRepository.findByPhone(PHONE)).thenReturn(Optional.of(disabled));

        assertThatThrownBy(() -> service.verifyOtp(PHONE, "123456"))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.ACCOUNT_DISABLED);
    }

    @Test
    @DisplayName("the stored refresh token is a digest, never the token itself")
    void refreshTokenStoredHashed() {
        when(userRepository.findByPhone(PHONE)).thenReturn(Optional.empty());

        AuthTokensResponse response = service.verifyOtp(PHONE, "123456");

        org.mockito.ArgumentCaptor<RefreshToken> saved =
                org.mockito.ArgumentCaptor.forClass(RefreshToken.class);
        verify(refreshTokenRepository).save(saved.capture());
        assertThat(saved.getValue().getTokenHash())
                .isNotEqualTo(response.refreshToken())
                .isEqualTo(hasher.hash(response.refreshToken()));
    }

    // ---- refresh rotation --------------------------------------------

    @Test
    @DisplayName("rotation revokes the presented row and inserts a new one")
    void rotationIsAppendStyle() {
        User owner = user(PHONE, UserRole.OWNER);
        String raw = hasher.newToken();
        RefreshToken stored = storedToken(owner.getId(), raw, Instant.now().plusSeconds(3600));
        when(refreshTokenRepository.findByTokenHash(hasher.hash(raw)))
                .thenReturn(Optional.of(stored));
        when(userRepository.findById(owner.getId())).thenReturn(Optional.of(owner));

        AuthTokensResponse response = service.refresh(raw);

        assertThat(stored.getRevokedAt())
                .as("the old row is revoked, not overwritten - history stays intact")
                .isNotNull();
        assertThat(response.refreshToken()).isNotEqualTo(raw);
        assertThat(response.isNewUser()).isFalse();
    }

    @Test
    @DisplayName("presenting a revoked token revokes the whole family")
    void reuseDetection() {
        User owner = user(PHONE, UserRole.OWNER);
        String raw = hasher.newToken();
        RefreshToken stored = storedToken(owner.getId(), raw, Instant.now().plusSeconds(3600));
        stored.setRevokedAt(Instant.now().minusSeconds(10));
        when(refreshTokenRepository.findByTokenHash(hasher.hash(raw)))
                .thenReturn(Optional.of(stored));

        assertThatThrownBy(() -> service.refresh(raw))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.REFRESH_TOKEN_REUSED);

        // Must go through the REQUIRES_NEW revoker: the exception above would
        // otherwise roll back the revocation of a token we know has leaked.
        verify(familyRevoker).revokeAllForUser(org.mockito.ArgumentMatchers.eq(owner.getId()), any());
    }

    @Test
    @DisplayName("an expired refresh token is invalid, not reuse")
    void expiredRefreshToken() {
        User owner = user(PHONE, UserRole.OWNER);
        String raw = hasher.newToken();
        RefreshToken stored = storedToken(owner.getId(), raw, Instant.now().minusSeconds(1));
        when(refreshTokenRepository.findByTokenHash(hasher.hash(raw)))
                .thenReturn(Optional.of(stored));

        assertThatThrownBy(() -> service.refresh(raw))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.REFRESH_TOKEN_INVALID);

        verify(familyRevoker, never()).revokeAllForUser(any(), any());
    }

    @Test
    @DisplayName("an unknown refresh token is invalid")
    void unknownRefreshToken() {
        when(refreshTokenRepository.findByTokenHash(any())).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.refresh("made-up"))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.REFRESH_TOKEN_INVALID);
    }

    // ---- logout ------------------------------------------------------

    @Test
    @DisplayName("logout revokes the caller's own token")
    void logoutRevokesOwnToken() {
        User owner = user(PHONE, UserRole.OWNER);
        String raw = hasher.newToken();
        RefreshToken stored = storedToken(owner.getId(), raw, Instant.now().plusSeconds(3600));
        when(refreshTokenRepository.findByTokenHash(hasher.hash(raw)))
                .thenReturn(Optional.of(stored));

        service.logout(owner.getId(), raw);

        assertThat(stored.getRevokedAt()).isNotNull();
    }

    @Test
    @DisplayName("logout cannot revoke someone else's token")
    void logoutCannotRevokeAnotherUsersToken() {
        User victim = user("+919000000001", UserRole.STUDENT);
        String raw = hasher.newToken();
        RefreshToken stored = storedToken(victim.getId(), raw, Instant.now().plusSeconds(3600));
        when(refreshTokenRepository.findByTokenHash(hasher.hash(raw)))
                .thenReturn(Optional.of(stored));

        service.logout(UUID.randomUUID(), raw);

        assertThat(stored.getRevokedAt()).isNull();
        verify(refreshTokenRepository, never()).save(any(RefreshToken.class));
    }

    // ---- profile / role settable once --------------------------------

    @Test
    @DisplayName("the first role choice is applied and stamped")
    void firstRoleChoiceSticks() {
        User fresh = user(PHONE, UserRole.STUDENT);
        when(userRepository.findById(fresh.getId())).thenReturn(Optional.of(fresh));

        UserResponse response = service.updateProfile(fresh.getId(),
                new UpdateProfileRequest("Asha Rao", UserRole.OWNER, Gender.FEMALE, null));

        assertThat(response.role()).isEqualTo(UserRole.OWNER);
        assertThat(response.roleLocked()).isTrue();
        assertThat(fresh.getRoleChosenAt()).isNotNull();
        assertThat(response.name()).isEqualTo("Asha Rao");
    }

    @Test
    @DisplayName("a second, different role is rejected")
    void roleIsSettableOnce() {
        User chosen = user(PHONE, UserRole.OWNER);
        chosen.setRoleChosenAt(Instant.now().minusSeconds(60));
        when(userRepository.findById(chosen.getId())).thenReturn(Optional.of(chosen));

        assertThatThrownBy(() -> service.updateProfile(chosen.getId(),
                new UpdateProfileRequest(null, UserRole.STUDENT, null, null)))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.ROLE_ALREADY_SET);

        assertThat(chosen.getRole()).isEqualTo(UserRole.OWNER);
    }

    @Test
    @DisplayName("re-sending the same role is a no-op, so a client retry is safe")
    void resendingSameRoleIsIdempotent() {
        User chosen = user(PHONE, UserRole.OWNER);
        Instant chosenAt = Instant.now().minusSeconds(60);
        chosen.setRoleChosenAt(chosenAt);
        when(userRepository.findById(chosen.getId())).thenReturn(Optional.of(chosen));

        UserResponse response = service.updateProfile(chosen.getId(),
                new UpdateProfileRequest(null, UserRole.OWNER, null, null));

        assertThat(response.role()).isEqualTo(UserRole.OWNER);
        assertThat(chosen.getRoleChosenAt()).isEqualTo(chosenAt);
    }

    @Test
    @DisplayName("admin cannot be self-assigned")
    void adminIsNotSelfAssignable() {
        User fresh = user(PHONE, UserRole.STUDENT);
        when(userRepository.findById(fresh.getId())).thenReturn(Optional.of(fresh));

        assertThatThrownBy(() -> service.updateProfile(fresh.getId(),
                new UpdateProfileRequest(null, UserRole.ADMIN, null, null)))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.FORBIDDEN);
    }

    @Test
    @DisplayName("email is lowercased on write, because uq_users_email is on lower(email)")
    void emailIsLowercased() {
        User fresh = user(PHONE, UserRole.STUDENT);
        when(userRepository.findById(fresh.getId())).thenReturn(Optional.of(fresh));
        when(userRepository.findByEmail("asha@example.com")).thenReturn(Optional.empty());

        UserResponse response = service.updateProfile(fresh.getId(),
                new UpdateProfileRequest(null, null, null, "  Asha@Example.COM  "));

        assertThat(response.email()).isEqualTo("asha@example.com");
    }

    @Test
    @DisplayName("an email another live user holds is rejected as EMAIL_TAKEN")
    void emailUniqueness() {
        User fresh = user(PHONE, UserRole.STUDENT);
        User other = user("+919000000002", UserRole.STUDENT);
        when(userRepository.findById(fresh.getId())).thenReturn(Optional.of(fresh));
        when(userRepository.findByEmail("taken@example.com")).thenReturn(Optional.of(other));

        assertThatThrownBy(() -> service.updateProfile(fresh.getId(),
                new UpdateProfileRequest(null, null, null, "Taken@Example.com")))
                .isInstanceOf(ApiException.class)
                .extracting(e -> ((ApiException) e).getCode())
                .isEqualTo(ErrorCode.EMAIL_TAKEN);
    }

    @Test
    @DisplayName("keeping your own email is not a conflict with yourself")
    void ownEmailIsNotAConflict() {
        User self = user(PHONE, UserRole.STUDENT);
        self.setEmail("mine@example.com");
        when(userRepository.findById(self.getId())).thenReturn(Optional.of(self));
        when(userRepository.findByEmail("mine@example.com")).thenReturn(Optional.of(self));

        UserResponse response = service.updateProfile(self.getId(),
                new UpdateProfileRequest(null, null, null, "Mine@Example.com"));

        assertThat(response.email()).isEqualTo("mine@example.com");
    }

    @Test
    @DisplayName("an absent field is left alone - this is a patch, not a put")
    void absentFieldsAreUntouched() {
        User existing = user(PHONE, UserRole.OWNER);
        existing.setName("Original");
        existing.setGender(Gender.MALE);
        existing.setRoleChosenAt(Instant.now());
        when(userRepository.findById(existing.getId())).thenReturn(Optional.of(existing));

        UserResponse response = service.updateProfile(existing.getId(),
                new UpdateProfileRequest(null, null, null, null));

        assertThat(response.name()).isEqualTo("Original");
        assertThat(response.gender()).isEqualTo(Gender.MALE);
        assertThat(response.role()).isEqualTo(UserRole.OWNER);
    }

    @Test
    @DisplayName("the family revoker is only reached through reuse detection")
    void revokerNotCalledOnHappyPath() {
        User owner = user(PHONE, UserRole.OWNER);
        String raw = hasher.newToken();
        when(refreshTokenRepository.findByTokenHash(hasher.hash(raw)))
                .thenReturn(Optional.of(storedToken(owner.getId(), raw, Instant.now().plusSeconds(3600))));
        when(userRepository.findById(owner.getId())).thenReturn(Optional.of(owner));
        when(refreshTokenRepository.findAllByUserIdAndRevokedAtIsNull(owner.getId()))
                .thenReturn(List.of());

        service.refresh(raw);

        verify(familyRevoker, never()).revokeAllForUser(any(), any());
    }
}
