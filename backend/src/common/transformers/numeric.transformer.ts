import { ValueTransformer } from 'typeorm';

/**
 * Postgres `bigint` comes back from the driver as a string. All money in this
 * system is paise (CLAUDE.md §3.7); even ₹10 crore is 1e11 paise, far below
 * Number.MAX_SAFE_INTEGER (~9e15), so a plain number is safe and far easier to
 * work with in DTOs than a string.
 */
export const bigintTransformer: ValueTransformer = {
  to: (value?: number | null) => value,
  from: (value?: string | null) =>
    value === null || value === undefined ? value : parseInt(value, 10),
};

/**
 * Postgres `decimal` also arrives as a string. Used for latitude/longitude.
 */
export const decimalTransformer: ValueTransformer = {
  to: (value?: number | null) => value,
  from: (value?: string | null) =>
    value === null || value === undefined ? value : parseFloat(value),
};
