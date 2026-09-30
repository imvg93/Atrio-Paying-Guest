export enum PropertyGenderType {
  MALE = 'male',
  FEMALE = 'female',
  COLIVING = 'coliving',
}

export enum PropertyStatus {
  DRAFT = 'draft',
  PUBLISHED = 'published',
  UNLISTED = 'unlisted',
}

/**
 * Free-form on purpose (CLAUDE.md §3.6): stored as JSONB so new amenities need
 * no migration. `GET /meta/amenities` will serve the canonical list.
 */
export type PropertyAmenities = Record<string, boolean>;

export type PropertyRules = Record<string, unknown>;
