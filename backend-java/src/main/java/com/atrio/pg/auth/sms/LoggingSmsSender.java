package com.atrio.pg.auth.sms;

import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Development stand-in: writes the code to the application log instead of
 * sending it.
 *
 * <p>{@code @Profile("!prod")} is what keeps this safe. The code is a login
 * credential, and logging it is only acceptable because this bean cannot exist
 * in production - {@link DisabledSmsSender} takes its place there. Do not
 * relax this to a configuration flag.
 */
@Component
@Profile("!prod")
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
