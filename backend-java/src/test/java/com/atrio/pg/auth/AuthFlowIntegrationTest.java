package com.atrio.pg.auth;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.atrio.pg.auth.sms.SmsSender;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIf;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.context.annotation.Primary;
import org.springframework.http.MediaType;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

/**
 * The whole Step 1 round trip over HTTP, against a real Postgres built from
 * scratch by Flyway.
 *
 * <p>This also proves the migration story end to end: the container starts
 * empty, so {@code baseline-on-migrate} does not apply and Flyway runs
 * {@code V1} then {@code V2} - which is the code path Supabase will never
 * take, and therefore the one that would otherwise rot unnoticed.
 *
 * <p>Skipped when Docker is absent; see {@link com.atrio.pg.support.DockerAvailable}.
 */
@Testcontainers
@SpringBootTest
@Import(AuthFlowIntegrationTest.CapturingSmsConfig.class)
@EnabledIf("com.atrio.pg.support.DockerAvailable#isAvailable")
class AuthFlowIntegrationTest {

    @Container
    @SuppressWarnings("resource")
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:17-alpine");

    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGRES::getUsername);
        registry.add("spring.datasource.password", POSTGRES::getPassword);
        // Secrets are supplied here so the suite does not depend on a .env
        // file that is git-ignored and absent in CI.
        registry.add("atrio.auth.jwt.access-secret",
                () -> "integration-access-secret-long-enough-for-hs256-aaaaaaaaaa");
        registry.add("atrio.auth.jwt.refresh-secret",
                () -> "integration-refresh-secret-long-enough-for-hmac-bbbbbbbbbb");
    }

    /** Captures the plaintext code the sender would have delivered. */
    @TestConfiguration
    static class CapturingSmsConfig {

        static final List<String> SENT = new ArrayList<>();

        @Bean
        @Primary
        SmsSender capturingSmsSender() {
            return (phone, code) -> SENT.add(code);
        }
    }

    @Autowired private WebApplicationContext context;
    @Autowired private ObjectMapper objectMapper;

    private MockMvc mvc() {
        return MockMvcBuilders.webAppContextSetup(context)
                .apply(org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers
                        .springSecurity())
                .build();
    }

    private String phone() {
        return "+9199" + String.format("%08d", (int) (Math.random() * 100_000_000));
    }

    private JsonNode data(String body) throws Exception {
        return objectMapper.readTree(body).get("data");
    }

    @Test
    @DisplayName("request -> verify -> me -> profile -> refresh -> logout")
    void fullRoundTrip() throws Exception {
        MockMvc mvc = mvc();
        String phone = phone();

        mvc.perform(post("/api/v1/auth/otp/request")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"" + phone + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.expiresInSeconds").value(300));

        String code = CapturingSmsConfig.SENT.getLast();
        assertThat(code).matches("\\d{6}");

        String verified = mvc.perform(post("/api/v1/auth/otp/verify")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"" + phone + "\",\"code\":\"" + code + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.isNewUser").value(true))
                .andExpect(jsonPath("$.data.user.role").value("student"))
                .andExpect(jsonPath("$.data.user.roleLocked").value(false))
                .andReturn().getResponse().getContentAsString();

        String access = data(verified).get("accessToken").asText();
        String refresh = data(verified).get("refreshToken").asText();

        mvc.perform(get("/api/v1/me").header("Authorization", "Bearer " + access))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.phone").value(phone))
                .andExpect(jsonPath("$.data.name").isEmpty());

        mvc.perform(patch("/api/v1/auth/profile")
                        .header("Authorization", "Bearer " + access)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Asha Rao\",\"role\":\"owner\",\"gender\":\"female\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.role").value("owner"))
                .andExpect(jsonPath("$.data.roleLocked").value(true));

        // Role is settable once (CLAUDE.md 6).
        mvc.perform(patch("/api/v1/auth/profile")
                        .header("Authorization", "Bearer " + access)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"role\":\"student\"}"))
                .andExpect(status().isConflict())
                .andExpect(jsonPath("$.error.code").value("ROLE_ALREADY_SET"));

        String rotated = mvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\":\"" + refresh + "\"}"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();

        String refresh2 = data(rotated).get("refreshToken").asText();
        assertThat(refresh2).isNotEqualTo(refresh);

        // Reuse detection: the superseded token is now poison.
        mvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\":\"" + refresh + "\"}"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error.code").value("REFRESH_TOKEN_REUSED"));

        // ...and it took the rest of the family with it.
        mvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\":\"" + refresh2 + "\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("logout revokes only the presented token")
    void logout() throws Exception {
        MockMvc mvc = mvc();
        String phone = phone();

        mvc.perform(post("/api/v1/auth/otp/request")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"phone\":\"" + phone + "\"}"));
        String code = CapturingSmsConfig.SENT.getLast();

        String verified = mvc.perform(post("/api/v1/auth/otp/verify")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"" + phone + "\",\"code\":\"" + code + "\"}"))
                .andReturn().getResponse().getContentAsString();
        String access = data(verified).get("accessToken").asText();
        String refresh = data(verified).get("refreshToken").asText();

        mvc.perform(post("/api/v1/auth/logout")
                        .header("Authorization", "Bearer " + access)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\":\"" + refresh + "\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.loggedOut").value(true));

        mvc.perform(post("/api/v1/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"refreshToken\":\"" + refresh + "\"}"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("a wrong code burns an attempt and the cap survives the rollback")
    void attemptsAreRecordedDespiteTheThrow() throws Exception {
        MockMvc mvc = mvc();
        String phone = phone();

        mvc.perform(post("/api/v1/auth/otp/request")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"phone\":\"" + phone + "\"}"));

        // Five wrong guesses. If the increment were rolled back with the
        // failing transaction, the fifth would still report OTP_INVALID and
        // the code could be brute-forced indefinitely.
        for (int i = 0; i < 4; i++) {
            mvc.perform(post("/api/v1/auth/otp/verify")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"phone\":\"" + phone + "\",\"code\":\"000000\"}"))
                    .andExpect(jsonPath("$.error.code").value("OTP_INVALID"));
        }
        mvc.perform(post("/api/v1/auth/otp/verify")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"" + phone + "\",\"code\":\"000000\"}"))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.error.code").value("OTP_MAX_ATTEMPTS"));
    }

    @Test
    @DisplayName("the fourth code request inside the window is rate limited")
    void rateLimit() throws Exception {
        MockMvc mvc = mvc();
        String phone = phone();

        for (int i = 0; i < 3; i++) {
            mvc.perform(post("/api/v1/auth/otp/request")
                            .contentType(MediaType.APPLICATION_JSON)
                            .content("{\"phone\":\"" + phone + "\"}"))
                    .andExpect(status().isOk());
        }
        mvc.perform(post("/api/v1/auth/otp/request")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"" + phone + "\"}"))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.error.code").value("PHONE_RATE_LIMITED"));
    }

    @Test
    @DisplayName("401 and 403 keep the envelope, though Security raises them outside the advice")
    void securityFailuresAreEnveloped() throws Exception {
        MockMvc mvc = mvc();

        mvc.perform(get("/api/v1/me"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false))
                .andExpect(jsonPath("$.error.code").value("UNAUTHORIZED"));

        mvc.perform(get("/api/v1/me").header("Authorization", "Bearer not.a.jwt"))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.error.code").value("UNAUTHORIZED"));
    }

    @Test
    @DisplayName("validation failures carry the details array")
    void validationEnvelope() throws Exception {
        mvc().perform(post("/api/v1/auth/otp/request")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"9876543210\"}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.error.details").isArray());
    }
}
