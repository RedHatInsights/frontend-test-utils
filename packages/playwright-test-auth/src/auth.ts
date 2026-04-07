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

// Prevents inconsistent cookie prompting that is problematic for UI testing
// Note: subsequent calls to page.route may inadvertently override this
export async function disableCookiePrompt(page: Page) {
  await page.route('**/*', async (route, request) => {
    if (isBlockedCookieConsentHost(request.url()) && request.resourceType() !== 'document') {
      await route.abort();
    } else {
      await route.continue();
    }
  });
}

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

