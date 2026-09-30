package com.atrio.pg.health;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import javax.sql.DataSource;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * GET /api/v1/health
 *
 * <p>Response (after {@code SuccessBodyAdvice} envelopes it):
 * <pre>
 * { "success": true,
 *   "data": { "status": "ok", "service": "atrio-pg-api",
 *             "version": "0.1.0-SNAPSHOT", "database": "up",
 *             "time": "2026-07-24T18:15:16.123Z" } }
 * </pre>
 */
@RestController
@RequestMapping("/health")
@RequiredArgsConstructor
@Slf4j
public class HealthController {

    private final DataSource dataSource;

    @Value("${spring.application.name:atrio-pg-api}")
    private String serviceName;

    @Value("${info.app.version:0.1.0-SNAPSHOT}")
    private String version;

    @GetMapping
    public Map<String, Object> health() {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("status", "ok");
        body.put("service", serviceName);
        body.put("version", version);
        body.put("database", probeDatabase());
        body.put("time", Instant.now());
        return body;
    }

    /** A real round trip, not just "is a pool configured". */
    private String probeDatabase() {
        try (var connection = dataSource.getConnection();
             var statement = connection.createStatement();
             var rs = statement.executeQuery("SELECT 1")) {
            return rs.next() ? "up" : "down";
        } catch (Exception e) {
            log.warn("Database health probe failed", e);
            return "down";
        }
    }
}
