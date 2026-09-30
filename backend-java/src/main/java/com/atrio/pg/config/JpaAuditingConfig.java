package com.atrio.pg.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

/** Activates @CreatedDate / @LastModifiedDate on {@code BaseEntity}. */
@Configuration
@EnableJpaAuditing
public class JpaAuditingConfig {
}
