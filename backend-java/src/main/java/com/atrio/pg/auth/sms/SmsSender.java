package com.atrio.pg.auth.sms;

/**
 * Delivers a one-time code to a phone.
 *
 * <p><strong>No SMS provider has been chosen for this project</strong>
 * (docs/CURRENT_STATE.md 5.1). This interface exists so that decision stays a
 * one-class change: pick MSG91 / Twilio / Gupshup later, add an implementation,
 * and nothing in {@code OtpService} moves.
 *
 * <p>Two implementations ship today - {@link LoggingSmsSender} for development
 * and {@link DisabledSmsSender} for production - and they are selected by
 * profile, not by configuration, so the development one cannot be switched on
 * in production by editing a value.
 */
public interface SmsSender {

    /**
     * @param phone E.164 destination, e.g. {@code +919876543210}
     * @param code  the plaintext one-time code
     */
    void sendOtp(String phone, String code);
}
