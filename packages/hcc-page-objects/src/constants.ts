/**
 * Timeout constants for page object operations
 */

/**
 * Timeout for search operations.
 * Search uses local Orama index query which loads asynchronously on page load.
 * This timeout accounts for async index loading + query execution time in CI.
 */
export const SEARCH_TIMEOUT = 10000; // 10 seconds
