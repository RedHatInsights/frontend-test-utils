/**
 * Example of how to use frontend-playwright-test-utils in your Playwright tests
 *
 * This file demonstrates the usage patterns but is not meant to be executed directly.
 */

import { test, expect } from '@playwright/test';
import { login } from 'frontend-playwright-test-utils';

// Example 1: Basic usage of login helper
test('authenticated user can view dashboard', async ({ page }) => {
  // Perform login using the shared utility
  await login(page);

  // Navigate to dashboard
  await page.goto('/dashboard');

  // Your test assertions
  await expect(page.getByRole('heading', { name: 'Dashboard' })).toBeVisible();
});

// Example 2: Login once, then run multiple actions
test('authenticated user workflow', async ({ page }) => {
  await login(page);

  // Multiple actions after login
  await page.goto('/settings');
  await expect(page).toHaveURL('/settings');

  await page.goto('/profile');
  await expect(page).toHaveURL('/profile');
});

// Example 3: Using with test.beforeEach for multiple tests
test.describe('Authenticated features', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test in this describe block
    await login(page);
  });

  test('can access settings', async ({ page }) => {
    await page.goto('/settings');
    await expect(page).toHaveURL('/settings');
  });

  test('can access profile', async ({ page }) => {
    await page.goto('/profile');
    await expect(page).toHaveURL('/profile');
  });
});
