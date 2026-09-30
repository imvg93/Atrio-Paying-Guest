export enum SharingType {
  SINGLE = 'single',
  DOUBLE = 'double',
  TRIPLE = 'triple',
  FOUR_PLUS = 'four_plus',
}

/**
 * Bed count auto-created with a room (CLAUDE.md §6, Owner). `four_plus` is a
 * floor, not an exact count — the owner can add more beds after creation.
 */
export const BEDS_PER_SHARING_TYPE: Record<SharingType, number> = {
  [SharingType.SINGLE]: 1,
  [SharingType.DOUBLE]: 2,
  [SharingType.TRIPLE]: 3,
  [SharingType.FOUR_PLUS]: 4,
};
