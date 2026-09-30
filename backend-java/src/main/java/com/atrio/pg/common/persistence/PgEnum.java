package com.atrio.pg.common.persistence;

/**
 * Implemented by every enum backed by a Postgres named enum type.
 *
 * <p>The database labels are lowercase ({@code student}, {@code four_plus},
 * {@code in_progress}) while Java constants are conventionally uppercase, so
 * the mapping must be explicit rather than derived from {@code name()}.
 *
 * <p>MIGRATION_PLAN.md 4.5 proposed naming the Java constants exactly as the DB
 * labels. That turned out to be impossible: {@code rooms_sharing_type_enum} has
 * a label {@code double}, which is a Java keyword and cannot be an identifier.
 * An explicit value mapping is therefore used for all 11 enums, which is also
 * the more conventional Java approach.
 */
public interface PgEnum {

    /** The exact label stored in the Postgres enum type. */
    String dbValue();
}
