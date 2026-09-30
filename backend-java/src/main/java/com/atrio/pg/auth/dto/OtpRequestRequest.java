package com.atrio.pg.auth.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

/**
 * Body of {@code POST /auth/otp/request}.
 *
 * <p>Phone is E.164 because that is what {@code users.phone varchar(15)}
 * stores and what the Flutter client sends ({@code +91} + 10 digits).
 */
public record OtpRequestRequest(
        @NotBlank(message = "is required")
        @Size(max = 15, message = "must be at most 15 characters")
        @Pattern(regexp = "^\\+[1-9]\\d{7,14}$",
                message = "must be an E.164 phone number, e.g. +919876543210")
        String phone) {
}
