package com.atrio.pg.auth.web;

import com.atrio.pg.auth.dto.AuthTokensResponse;
import com.atrio.pg.auth.dto.LogoutResponse;
import com.atrio.pg.auth.dto.OtpRequestRequest;
import com.atrio.pg.auth.dto.OtpRequestResponse;
import com.atrio.pg.auth.dto.OtpVerifyRequest;
import com.atrio.pg.auth.dto.RefreshRequest;
import com.atrio.pg.auth.dto.UpdateProfileRequest;
import com.atrio.pg.auth.security.AppUserPrincipal;
import com.atrio.pg.auth.service.AuthService;
import com.atrio.pg.users.dto.UserResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * {@code /api/v1/auth/*} - CLAUDE.md 6.
 *
 * <p>No logic here beyond binding and delegation; ownership and rules live in
 * {@link AuthService} (CLAUDE.md 3.13, 3.14). Every handler returns a body -
 * the client unwraps the {@code {success, data}} envelope and treats an empty
 * response as a broken contract, so {@code void} handlers are not an option.
 */
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    /** Public. Rate limited to OTP_REQUEST_LIMIT per phone per window. */
    @PostMapping("/otp/request")
    public OtpRequestResponse requestOtp(@Valid @RequestBody OtpRequestRequest request) {
        return authService.requestOtp(request.phone());
    }

    /** Public. Creates the account on first successful verify. */
    @PostMapping("/otp/verify")
    public AuthTokensResponse verifyOtp(@Valid @RequestBody OtpVerifyRequest request) {
        return authService.verifyOtp(request.phone(), request.code());
    }

    /**
     * Public: the access token is expired by definition when this is called,
     * so the refresh token in the body is the only credential presented.
     */
    @PostMapping("/refresh")
    public AuthTokensResponse refresh(@Valid @RequestBody RefreshRequest request) {
        return authService.refresh(request.refreshToken());
    }

    /** Authenticated, so a token can only be revoked by its own owner. */
    @PostMapping("/logout")
    public LogoutResponse logout(@AuthenticationPrincipal AppUserPrincipal caller,
                                 @Valid @RequestBody RefreshRequest request) {
        authService.logout(caller.id(), request.refreshToken());
        return LogoutResponse.done();
    }

    /** Authenticated. Completes the profile; role is settable once. */
    @PatchMapping("/profile")
    public UserResponse updateProfile(@AuthenticationPrincipal AppUserPrincipal caller,
                                      @Valid @RequestBody UpdateProfileRequest request) {
        return authService.updateProfile(caller.id(), request);
    }
}
