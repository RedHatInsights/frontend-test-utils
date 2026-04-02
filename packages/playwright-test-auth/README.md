# @redhat-cloud-services/playwright-test-auth

Reusable Red Hat SSO authentication utilities for Playwright e2e testing.

## Installation

```bash
npm install --save-dev @redhat-cloud-services/playwright-test-auth
```

## Usage

### Global Setup (Recommended)

Configure Playwright to use the global setup to authenticate once and reuse the session across all tests:

**playwright.config.ts:**
```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  globalSetup: require.resolve('@redhat-cloud-services/playwright-test-auth/global-setup'),
  use: {
    baseURL: 'https://stage.foo.redhat.com:1337',
    storageState: 'playwright/.auth/user.json',
  },
  // ... other config
});
```

Set environment variables:
```bash
export E2E_USER='your-username'
export E2E_PASSWORD='your-password'
```

### Test Setup

Block cookie prompts in your tests:

```typescript
import { test } from '@playwright/test';
import { disableCookiePrompt } from '@redhat-cloud-services/playwright-test-auth';

test.beforeEach(async ({ page }) => {
  await disableCookiePrompt(page);
  await page.goto('/');
});
```

### Manual Login

For tests that need to handle login manually:

```typescript
import { login, ensureLoggedIn } from '@redhat-cloud-services/playwright-test-auth';

// Direct login
await login(page, username, password);

// Or check if already logged in, login if needed
await ensureLoggedIn(page);
```

## API

### `globalSetup(config: FullConfig)`

Playwright global setup function that performs login once and saves authentication state.

### `disableCookiePrompt(page: Page)`

Blocks TrustArc cookie consent prompts to prevent flaky tests.

### `login(page: Page, user: string, password: string)`

Performs Red Hat SSO login flow.

**Parameters:**
- `page`: Playwright Page object
- `user`: Username for authentication
- `password`: Password for authentication

### `ensureLoggedIn(page: Page)`

Checks if user is already logged in. If not, performs login using `E2E_USER` and `E2E_PASSWORD` environment variables.

**Parameters:**
- `page`: Playwright Page object

### `APP_TEST_HOST_PORT`

Default test host: `'stage.foo.redhat.com:1337'`

## Environment Variables

- `E2E_USER` - Username for authentication
- `E2E_PASSWORD` - Password for authentication

## Technical Notes

### Import Strategy

This package uses `playwright` imports instead of `@playwright/test` to avoid the "Requiring @playwright/test second time" error that occurs when using functions in global setup files. This is a Playwright requirement - global setup files must use the core `playwright` library.

All relative imports include `.js` extensions for proper ESM module resolution.

### Error Handling

The auth functions use standard JavaScript error throwing instead of Playwright's `expect` assertions. This makes them safe to use in global setup without any dependency chain issues, while still providing clear error messages:

- `'Proxy config incorrect - Lockdown page detected'` - when proxy configuration is wrong
- `'Invalid login credentials'` - when login fails
- `'Login failed - user greeting not displayed'` - when post-login verification fails

## License

ISC
