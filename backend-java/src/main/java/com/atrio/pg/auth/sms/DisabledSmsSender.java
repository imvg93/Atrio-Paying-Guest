package com.atrio.pg.auth.sms;

import com.atrio.pg.common.exception.ApiException;
import com.atrio.pg.common.exception.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Production stand-in until a real provider is wired up: refuses to pretend.
 *
 * <p>The alternative - falling back to logging, or quietly doing nothing - would
 * let a production deployment accept OTP requests, return 200, and never
 * deliver a code. Failing loudly with a 503 makes the missing provider visible
 * the first time anyone tries to sign in.
 */
@Component
@Profile("prod")
@Slf4j
public class DisabledSmsSender implements SmsSender {

    @Override
    public void sendOtp(String phone, String code) {
        log.error("OTP requested for {} but no SMS provider is configured", phone);
        throw new ApiException(
                ErrorCode.SMS_DELIVERY_UNAVAILABLE,
                "Cannot send verification codes right now. Please try again later.");
    }
}
