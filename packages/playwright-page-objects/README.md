# @redhat-cloud-services/playwright-page-objects

Shared Playwright page objects for testing against the Red Hat Hybrid Cloud Console (HCC) chrome shell.

## Installation

```bash
npm install -D @redhat-cloud-services/playwright-page-objects
```

## Usage

```typescript
import { ChromeTopbar, ChromeNavigation, ChromeSearch } from '@redhat-cloud-services/playwright-page-objects';

test('navigate and search', async ({ page }) => {
  const topbar = new ChromeTopbar(page);
  const navigation = new ChromeNavigation(page);
  const search = new ChromeSearch(page);

  // Open user menu and get org ID
  const orgId = await topbar.getOrgId();

  // Navigate using sidebar
  await navigation.navigateToPage(['Settings', 'Integrations']);

  // Search for a service
  await search.search('Advisor');
  const results = await search.getResultTitles();
});
```

## Page Objects

### ChromeTopbar

Interact with the Chrome masthead/topbar: user menu, org ID, help, settings, services dropdown.

### ChromeNavigation

Interact with the Chrome sidebar navigation: toggle, item selection, nested navigation.

### ChromeSearch

Interact with the platform search: open, search, read results, click results.

## Peer Dependencies

- `@playwright/test` >= 1.40.0
