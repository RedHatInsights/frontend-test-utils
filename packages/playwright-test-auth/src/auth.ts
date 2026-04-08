import type { Page } from 'playwright';

// Allowlist of hosts for cookie consent services that should be blocked
const BLOCKED_COOKIE_CONSENT_HOSTS = new Set([
  'consent.trustarc.com',
  'consent-pref.trustarc.com',
]);

/**
 * Checks if a URL's hostname matches any blocked cookie consent hosts
 * @param url - The URL string to check
 * @returns true if the hostname is in the blocked list, false otherwise
 */
function isBlockedCookieConsentHost(url: string): boolean {
  try {
    const parsedUrl = new URL(url);
    return BLOCKED_COOKIE_CONSENT_HOSTS.has(parsedUrl.hostname);
  } catch {
    // Invalid URL, don't block it
    return false;
  }
}

/**
 * Disables cookie consent prompts that can interfere with UI testing.
 *
 * Blocks requests to TrustArc cookie consent services to prevent inconsistent
 * cookie prompts during test execution.
 *
 * @param page - The Playwright page instance to configure
 * @returns A promise that resolves when the route handler is set up
 *
 * @remarks
 * Note: subsequent calls to page.route may inadvertently override this handler.
 * Consider calling this function last in your setup sequence.
 *
 * @example
 * ```typescript
 * import { disableCookiePrompt } from '@redhat-cloud-services/playwright-test-auth';
 *
 * test.beforeEach(async ({ page }) => {
 *   await disableCookiePrompt(page);
 * });
 * ```
 */
export async function disableCookiePrompt(page: Page) {
  await page.route('**/*', async (route, request) => {
    if (isBlockedCookieConsentHost(request.url()) && request.resourceType() !== 'document') {
      await route.abort();
    } else {
      await route.continue();
    }
  });
}

/**
 * Performs Red Hat SSO login using provided credentials.
 *
 * Handles the complete login flow including username entry, password entry,
 * and verification of successful authentication.
 *
 * @param page - The Playwright page instance to perform login on
 * @param user - The Red Hat username/email
 * @param password - The user's password
 * @returns A promise that resolves when login is complete and verified
 *
 * @throws {Error} If proxy configuration is incorrect (Lockdown page detected)
 * @throws {Error} If login credentials are invalid
 *
 * @example
 * ```typescript
 * import { login } from '@redhat-cloud-services/playwright-test-auth';
 *
 * test('authenticated test', async ({ page }) => {
 *   await page.goto('https://console.redhat.com');
 *   await login(page, process.env.RH_USER!, process.env.RH_PASSWORD!);
 *   // Continue with authenticated test...
 * });
 * ```
 */
export async function login(page: Page, user: string, password: string): Promise<void> {
  // Fail in a friendly way if the proxy config is not set up correctly
  const lockdownCount = await page.locator("text=Lockdown").count();
  if (lockdownCount > 0) {
    throw new Error('Proxy config incorrect - Lockdown page detected');
  }

  // Wait for and fill username field
  await page.getByLabel('Red Hat login').first().fill(user);
  await page.getByRole('button', { name: 'Next' }).click();

  // Wait for and fill password field
  await page.getByLabel('Password').first().fill(password);
  await page.getByRole('button', { name: 'Log in' }).click();

  // Confirm login was valid
  const invalidLoginVisible = await page.getByText('Invalid login').isVisible().catch(() => false);
  if (invalidLoginVisible) {
    throw new Error('Invalid login credentials');
  }

  // Explicitly navigate to the landing page
  await page.goto(`/`, { waitUntil: 'load', timeout: 60000 });

  // Wait for the greeting to appear - this is the standard greeting on the landing page
  await page.getByText('Hi,').waitFor({ state: 'visible', timeout: 60000 });
}

