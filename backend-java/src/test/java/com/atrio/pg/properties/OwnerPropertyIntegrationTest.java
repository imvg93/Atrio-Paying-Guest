package com.atrio.pg.properties;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import com.atrio.pg.auth.sms.SmsSender;
import com.atrio.pg.users.domain.UserRole;
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
 * The Wave 1 property endpoints over real HTTP against a real Postgres.
 *
 * <p>What the unit tests cannot reach and this can: the JSONB round trip for
 * amenities, the named-enum converters on {@code gender_type} and
 * {@code status}, {@code @SQLDelete} actually performing a soft delete, and
 * that {@code @SQLRestriction} then hides the row from the list.
 *
 * <p>Skipped when Docker is absent; see {@link com.atrio.pg.support.DockerAvailable}.
 */
@Testcontainers
@SpringBootTest
@Import(OwnerPropertyIntegrationTest.CapturingSmsConfig.class)
@EnabledIf("com.atrio.pg.support.DockerAvailable#isAvailable")
class OwnerPropertyIntegrationTest {

    @Container
    @SuppressWarnings("resource")
    static final PostgreSQLContainer<?> POSTGRES =
            new PostgreSQLContainer<>("postgres:17-alpine");

    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGRES::getUsername);
        registry.add("spring.datasource.password", POSTGRES::getPassword);
        registry.add("atrio.auth.jwt.access-secret",
                () -> "integration-access-secret-long-enough-for-hs256-aaaaaaaaaa");
        registry.add("atrio.auth.jwt.refresh-secret",
                () -> "integration-refresh-secret-long-enough-for-hmac-bbbbbbbbbb");
    }

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

    private static final String VALID_BODY = """
            {
              "name": "Sunrise PG",
              "description": "Five minutes from the metro",
              "genderType": "coliving",
              "addressLine": "12 MG Road",
              "locality": "Indiranagar",
              "city": "Bengaluru",
              "state": "Karnataka",
              "pincode": "560038",
              "latitude": 12.971599,
              "longitude": 77.594566,
              "amenities": {"wifi": true, "ac": false},
              "rules": {"gateClosingTime": "22:30"},
              "foodIncluded": true,
              "noticePeriodDays": 45
            }
            """;

    private MockMvc mvc() {
        return MockMvcBuilders.webAppContextSetup(context)
                .apply(org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers
                        .springSecurity())
                .build();
    }

    private JsonNode data(String body) throws Exception {
        return objectMapper.readTree(body).get("data");
    }

    /** Signs a brand-new account in and locks it to the given role. */
    private String tokenFor(MockMvc mvc, UserRole role) throws Exception {
        String phone = "+9199" + String.format("%08d", (int) (Math.random() * 100_000_000));

        mvc.perform(post("/api/v1/auth/otp/request")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"phone\":\"" + phone + "\"}"));
        String code = CapturingSmsConfig.SENT.getLast();

        String verified = mvc.perform(post("/api/v1/auth/otp/verify")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"" + phone + "\",\"code\":\"" + code + "\"}"))
                .andReturn().getResponse().getContentAsString();
        String access = data(verified).get("accessToken").asText();

        String updated = mvc.perform(patch("/api/v1/auth/profile")
                        .header("Authorization", "Bearer " + access)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Test User\",\"role\":\"" + role.dbValue() + "\"}"))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        assertThat(data(updated).get("role").asText()).isEqualTo(role.dbValue());

        // The role lives in the access token's claims, so a token minted before
        // the role was chosen still says "student". Refresh is not enough - the
        // claim is set at verify time - so sign in again on the same phone.
        mvc.perform(post("/api/v1/auth/otp/request")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"phone\":\"" + phone + "\"}"));
        String secondCode = CapturingSmsConfig.SENT.getLast();
        String reVerified = mvc.perform(post("/api/v1/auth/otp/verify")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"phone\":\"" + phone + "\",\"code\":\"" + secondCode + "\"}"))
                .andReturn().getResponse().getContentAsString();
        return data(reVerified).get("accessToken").asText();
    }

    private String createProperty(MockMvc mvc, String token) throws Exception {
        String created = mvc.perform(post("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_BODY))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return data(created).get("id").asText();
    }

    @Test
    @DisplayName("create -> read -> patch -> publish, with JSONB and enums surviving the trip")
    void lifecycle() throws Exception {
        MockMvc mvc = mvc();
        String token = tokenFor(mvc, UserRole.OWNER);

        String created = mvc.perform(post("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_BODY))
                .andExpect(status().isCreated())
                // Never publishable straight from POST.
                .andExpect(jsonPath("$.data.status").value("draft"))
                .andExpect(jsonPath("$.data.genderType").value("coliving"))
                .andExpect(jsonPath("$.data.amenities.wifi").value(true))
                .andExpect(jsonPath("$.data.rules.gateClosingTime").value("22:30"))
                .andExpect(jsonPath("$.data.noticePeriodDays").value(45))
                // No rooms yet, so the counts are zeros and the range is null.
                .andExpect(jsonPath("$.data.occupancy.totalBeds").value(0))
                .andExpect(jsonPath("$.data.minRentPaise").isEmpty())
                .andExpect(jsonPath("$.data.photos").isArray())
                .andReturn().getResponse().getContentAsString();

        String id = data(created).get("id").asText();

        mvc.perform(get("/api/v1/owner/properties/" + id)
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("Sunrise PG"))
                .andExpect(jsonPath("$.data.pincode").value("560038"))
                .andExpect(jsonPath("$.data.foodIncluded").value(true));

        // The decimal(9,6) round trip, checked against the parsed number rather
        // than a jsonPath literal - how the JSON provider widens 12.971599 is
        // not something this test should care about.
        String detail = mvc.perform(get("/api/v1/owner/properties/" + id)
                        .header("Authorization", "Bearer " + token))
                .andReturn().getResponse().getContentAsString();
        assertThat(data(detail).get("latitude").decimalValue())
                .isEqualByComparingTo("12.971599");

        mvc.perform(patch("/api/v1/owner/properties/" + id)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Sunrise PG Deluxe\",\"amenities\":{\"gym\":true}}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("Sunrise PG Deluxe"))
                // Replaced, not merged: wifi is gone.
                .andExpect(jsonPath("$.data.amenities.gym").value(true))
                .andExpect(jsonPath("$.data.amenities.wifi").doesNotExist())
                // Untouched by the patch.
                .andExpect(jsonPath("$.data.city").value("Bengaluru"));

        mvc.perform(patch("/api/v1/owner/properties/" + id + "/status")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"published\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.status").value("published"));
    }

    @Test
    @DisplayName("another owner gets 403 PROPERTY_NOT_OWNED on every verb")
    void anotherOwnerIsRefused() throws Exception {
        MockMvc mvc = mvc();
        String mine = tokenFor(mvc, UserRole.OWNER);
        String theirs = tokenFor(mvc, UserRole.OWNER);
        String id = createProperty(mvc, mine);

        mvc.perform(get("/api/v1/owner/properties/" + id)
                        .header("Authorization", "Bearer " + theirs))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.error.code").value("PROPERTY_NOT_OWNED"));

        mvc.perform(patch("/api/v1/owner/properties/" + id)
                        .header("Authorization", "Bearer " + theirs)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"name\":\"Hijacked\"}"))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.error.code").value("PROPERTY_NOT_OWNED"));

        mvc.perform(patch("/api/v1/owner/properties/" + id + "/status")
                        .header("Authorization", "Bearer " + theirs)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"unlisted\"}"))
                .andExpect(status().isForbidden());

        mvc.perform(delete("/api/v1/owner/properties/" + id)
                        .header("Authorization", "Bearer " + theirs))
                .andExpect(status().isForbidden());

        // And none of it landed.
        mvc.perform(get("/api/v1/owner/properties/" + id)
                        .header("Authorization", "Bearer " + mine))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.name").value("Sunrise PG"))
                .andExpect(jsonPath("$.data.status").value("draft"));

        // The other owner's list is empty, not filtered after the fact.
        mvc.perform(get("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + theirs))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.total").value(0));
    }

    @Test
    @DisplayName("a student is refused by the role guard before any ownership check runs")
    void studentsAreRefused() throws Exception {
        MockMvc mvc = mvc();
        String student = tokenFor(mvc, UserRole.STUDENT);

        mvc.perform(get("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + student))
                .andExpect(status().isForbidden())
                .andExpect(jsonPath("$.success").value(false));

        mvc.perform(post("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + student)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_BODY))
                .andExpect(status().isForbidden());
    }

    @Test
    @DisplayName("the list paginates, filters by status label, and hides soft-deleted rows")
    void listing() throws Exception {
        MockMvc mvc = mvc();
        String token = tokenFor(mvc, UserRole.OWNER);

        String first = createProperty(mvc, token);
        String second = createProperty(mvc, token);
        createProperty(mvc, token);

        mvc.perform(patch("/api/v1/owner/properties/" + second + "/status")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"status\":\"published\"}"))
                .andExpect(status().isOk());

        mvc.perform(get("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.total").value(3))
                .andExpect(jsonPath("$.data.page").value(1))
                .andExpect(jsonPath("$.data.limit").value(20))
                .andExpect(jsonPath("$.data.items.length()").value(3));

        mvc.perform(get("/api/v1/owner/properties?page=2&limit=2")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.page").value(2))
                .andExpect(jsonPath("$.data.limit").value(2))
                .andExpect(jsonPath("$.data.items.length()").value(1));

        // The filter is spelled with the database label, matching what the
        // response body emits - PgEnumConverterFactory is what makes that work.
        mvc.perform(get("/api/v1/owner/properties?status=published")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.total").value(1))
                .andExpect(jsonPath("$.data.items[0].id").value(second));

        mvc.perform(get("/api/v1/owner/properties?status=nonsense")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("VALIDATION_ERROR"));

        mvc.perform(delete("/api/v1/owner/properties/" + first)
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.deleted").value(true));

        // Soft-deleted, so gone from the list and from a direct read - but the
        // row is still in the table.
        mvc.perform(get("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + token))
                .andExpect(jsonPath("$.data.total").value(2));

        mvc.perform(get("/api/v1/owner/properties/" + first)
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.error.code").value("NOT_FOUND"));
    }

    @Test
    @DisplayName("validation rejects a bad pincode, an out-of-range pin, and an unknown field")
    void validation() throws Exception {
        MockMvc mvc = mvc();
        String token = tokenFor(mvc, UserRole.OWNER);

        mvc.perform(post("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_BODY.replace("\"560038\"", "\"56003\"")))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("VALIDATION_ERROR"))
                .andExpect(jsonPath("$.error.details").isArray());

        mvc.perform(post("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_BODY.replace("12.971599", "191.0")))
                .andExpect(status().isBadRequest());

        // forbidNonWhitelisted, via fail-on-unknown-properties.
        mvc.perform(post("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_BODY.replace("\"name\":", "\"sneaky\": 1, \"name\":")))
                .andExpect(status().isBadRequest());

        // Status is not settable through POST or PATCH - only through /status.
        mvc.perform(post("/api/v1/owner/properties")
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(VALID_BODY.replace("\"name\":",
                                "\"status\": \"published\", \"name\":")))
                .andExpect(status().isBadRequest());

        String id = createProperty(mvc, token);
        mvc.perform(patch("/api/v1/owner/properties/" + id)
                        .header("Authorization", "Bearer " + token)
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("{\"latitude\": 13.0}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error.code").value("BAD_REQUEST"));
    }

    @Test
    @DisplayName("the amenity catalogue is served from the API, not hardcoded in the app")
    void amenityCatalogue() throws Exception {
        MockMvc mvc = mvc();
        String token = tokenFor(mvc, UserRole.STUDENT);

        mvc.perform(get("/api/v1/meta/amenities")
                        .header("Authorization", "Bearer " + token))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.data.amenities").isArray())
                .andExpect(jsonPath("$.data.amenities[0].key").isNotEmpty())
                .andExpect(jsonPath("$.data.amenities[0].label").isNotEmpty());
    }
}
