# Frontend Playwright Test Utils

Reusable Playwright test utilities for frontend repositories.

## Installation

Install via npm:

```bash
npm install --save-dev frontend-playwright-test-utils
```

Or yarn:

```bash
yarn add -D frontend-playwright-test-utils
```

## Usage

### Authentication

The `login` function provides a reusable authentication flow:

```typescript
import { login } from 'frontend-playwright-test-utils';
import { test } from '@playwright/test';

test('my test', async ({ page }) => {
  await login(page);
  // Your test code here
});
```

#### Using with beforeEach

For tests that require authentication, use in a `beforeEach` hook:

```typescript
test.describe('Authenticated features', () => {
  test.beforeEach(async ({ page }) => {
    await login(page);
  });

  test('can access settings', async ({ page }) => {
    await page.goto('/settings');
    // Test assertions
  });
});
```

## Environment Variables

The authentication utilities require the following environment variables:
- `E2E_USER` - Username for login
- `E2E_PASSWORD` - Password for login

## Available Utilities

### Auth (`src/auth/`)
- `login(page)` - Performs login flow with TrustArc blocking and analytics disabling

### Navigation (`src/navigation/`)
- Coming soon

### Fixtures (`src/fixtures/`)
- Coming soon

## Development

### Setup

```bash
npm install
```

### Build

```bash
npm run build
```

### Publishing

To publish a new version:

1. Update the version in `package.json`
2. Build the package: `npm run build`
3. Publish to npm: `npm publish`

The `prepublishOnly` script ensures the package is built before publishing.

## Project Structure

- `src/auth/` - Authentication utilities (login flows, etc.)
- `src/navigation/` - Navigation helpers
- `src/fixtures/` - Reusable Playwright fixtures
- `examples/` - Usage examples (not published to npm)

## License

MIT
