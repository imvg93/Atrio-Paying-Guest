package com.atrio.pg.support;

import org.testcontainers.DockerClientFactory;

/**
 * Gate for tests that need a real Postgres.
 *
 * <p>Docker is not installed on the current development machine
 * (docs/CURRENT_STATE.md notes this), and a hard dependency on it would mean
 * {@code mvn test} fails for reasons unrelated to the code under test. These
 * tests skip instead, and start running the moment Docker appears - without
 * anyone remembering to re-enable them.
 *
 * <p>H2 is deliberately not used as a substitute: JSONB, named enums, partial
 * indexes and the {@code updated_at} triggers all behave differently there, so
 * a green H2 run would prove nothing about production.
 */
public final class DockerAvailable {

    private DockerAvailable() {
    }

    public static boolean isAvailable() {
        try {
            return DockerClientFactory.instance().isDockerAvailable();
        } catch (RuntimeException | LinkageError e) {
            return false;
        }
    }
}
