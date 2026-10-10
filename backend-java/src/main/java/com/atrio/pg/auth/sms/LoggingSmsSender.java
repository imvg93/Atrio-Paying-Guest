package com.atrio.pg.auth.sms;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Development stand-in: writes the code to the application log instead of
 * sending it.
 *
 * <p>{@code @Profile("local")} is what keeps this safe. The code is a login
 * credential, so this bean only exists when the {@code local} profile is
 * explicitly activated. Every other profile - including no profile at all -
 * gets {@link DisabledSmsSender}, so a deployment that forgets to set a profile
 * fails closed instead of leaking codes to the log. Do not relax this to a
 * configuration flag or a default profile.
 */
@Component
@Profile("local")
@Slf4j
public class LoggingSmsSender implements SmsSender {

    @Override
    public void sendOtp(String phone, String code) {
        log.info("""

                ==================== DEV OTP ====================
                  phone : {}
                  code  : {}
                  No SMS provider is configured; this code was not
                  sent anywhere. See auth/sms/SmsSender.
                =================================================
                """, phone, code);
    }
}
