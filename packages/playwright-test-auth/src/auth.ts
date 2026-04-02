import type { Page } from 'playwright';

// Prevents inconsistent cookie prompting that is problematic for UI testing
// Note: subsequent calls to page.route may inadvertently override this
export async function disableCookiePrompt(page: Page) {
  await page.route('**/*', async (route, request) => {
    if (request.url().includes('consent.trustarc.com') && request.resourceType() !== 'document') {
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

