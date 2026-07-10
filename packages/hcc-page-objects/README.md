# @redhat-cloud-services/hcc-page-objects

Reusable page objects for Red Hat Hybrid Cloud Console Playwright e2e testing.

## Features

- Shared page object models for HCC Chrome components
- Consistent selectors using OUIA component IDs
- Idempotent methods for reliable test execution
- TypeScript support included
- Built for Playwright test framework

## Requirements

- Node.js 20 or higher
- Playwright 1.40.0 or higher

## Installation

```bash
npm install --save-dev @redhat-cloud-services/hcc-page-objects
```

## Usage

### ChromeNavigation

Page object for interacting with the HCC sidebar navigation.

```typescript
import { test } from '@playwright/test';
import { ChromeNavigation } from '@redhat-cloud-services/hcc-page-objects';

test('navigate to a page', async ({ page }) => {
  await page.goto('/');

  const navigation = new ChromeNavigation(page);

  // Toggle navigation visibility
  await navigation.clickToggle();

  // Navigate through nested items
  await navigation.navigateToPage(['Notifications', 'Configure Events']);

  // Check currently selected items
  const selected = await navigation.getCurrentlySelected();
  console.log('Currently selected:', selected);
});
```

### ChromeSearch

Page object for interacting with the HCC platform search.

```typescript
import { test, expect } from '@playwright/test';
import { ChromeSearch } from '@redhat-cloud-services/hcc-page-objects';

test('search for a service', async ({ page }) => {
  await page.goto('/');

  const search = new ChromeSearch(page);

  // Perform a search
  await search.search('ansible');

  // Check results
  const titles = await search.getResultTitles();
  expect(titles.length).toBeGreaterThan(0);

  // Click a result
  await search.clickResultByTitle('Ansible Automation Platform');
});
```

### ChromeTopbar

Page object for interacting with the HCC topbar/masthead components.

```typescript
import { test, expect } from '@playwright/test';
import { ChromeTopbar } from '@redhat-cloud-services/hcc-page-objects';

test('interact with topbar menus', async ({ page }) => {
  await page.goto('/');

  const topbar = new ChromeTopbar(page);

  // Get organization ID from user menu
  const orgId = await topbar.getOrgId();
  expect(orgId).toBeTruthy();

  // Open settings menu
  await topbar.openSettings();
  const menuItems = await topbar.getSettingsMenuItems();
  console.log('Settings items:', menuItems);

  // Select a settings item by OUIA ID (more stable)
  await topbar.selectSettingsItemByOuiaId('chrome-settings-language');

  // Interact with services menu
  await topbar.openServices();
  await topbar.clickServiceByPlatform('Ansible');
});
```

## API Reference

### ChromeNavigation

**Constructor:**
- `new ChromeNavigation(page: Page)`

**Properties:**
- `navToggle: Locator` - Navigation toggle button
- `sidebar: Locator` - Sidebar panel

**Methods:**
- `clickToggle(): Promise<void>` - Toggles navigation visibility
- `isVisible(): Promise<boolean>` - Checks if sidebar is visible
- `selectItem(itemName: string): Promise<void>` - Selects navigation item by name
- `getCurrentlySelected(): Promise<string[]>` - Gets currently active navigation items
- `navigateToPage(navItems: string[]): Promise<void>` - Navigates through nested items

### ChromeSearch

**Constructor:**
- `new ChromeSearch(page: Page)`

**Properties:**
- `searchToggle: Locator` - Search toggle button
- `searchInput: Locator` - Search input field
- `searchMenu: Locator` - Search results menu
- `emptyState: Locator` - Empty state message

**Methods:**
- `open(): Promise<void>` - Opens search input (idempotent)
- `search(query: string): Promise<void>` - Performs search
- `clear(): Promise<void>` - Clears search input
- `getResults(): Locator` - Gets result item locators
- `getResultTitles(): Promise<string[]>` - Gets result titles
- `resultsContain(text: string): Promise<boolean>` - Checks if results contain text
- `isEmpty(): Promise<boolean>` - Checks if empty state is shown
- `getResultCount(): Promise<number>` - Gets number of results
- `waitForResults(timeout?: number): Promise<void>` - Waits for results
- `clickResult(index: number): Promise<void>` - Clicks result by index
- `clickResultByTitle(title: string): Promise<void>` - Clicks result by title

### ChromeTopbar

**Constructor:**
- `new ChromeTopbar(page: Page)`

**Properties:**
- `overflowActionsButton: Locator` - User menu button
- `orgIdElement: Locator` - Organization ID element
- `helpButton: Locator` - Help button
- `settingsButton: Locator` - Settings button
- `servicesButton: Locator` - Services menu button
- `notificationsBadge: Locator` - Notifications badge

**Methods:**

*User Menu:*
- `openOverflowActions(): Promise<void>` - Opens user menu (idempotent)
- `getOrgId(): Promise<string | null>` - Gets organization ID
- `isOrgIdVisible(): Promise<boolean>` - Checks if org ID is visible

*Help:*
- `openHelp(): Promise<void>` - Opens help menu

*Settings:*
- `isSettingsOpen(): Promise<boolean>` - Checks if settings menu is open
- `openSettings(): Promise<void>` - Opens settings menu (idempotent)
- `closeSettings(): Promise<void>` - Closes settings menu (idempotent)
- `getSettingsMenuItems(): Promise<string[]>` - Gets settings menu items
- `selectSettingsItem(itemName: string): Promise<void>` - Selects by text
- `selectSettingsItemByOuiaId(ouiaId: string): Promise<void>` - Selects by OUIA ID
- `hasSettingsMenuItem(ouiaId: string): Promise<boolean>` - Checks if item exists

*Services:*
- `isServicesMenuOpen(): Promise<boolean>` - Checks if services menu is open
- `openServices(): Promise<void>` - Opens services menu (idempotent)
- `closeServices(): Promise<void>` - Closes services menu (idempotent)
- `getServiceLink(ouiaId: string): Locator` - Gets service link by OUIA ID
- `getServiceLinkByPlatform(platformName: string): Locator` - Gets service by platform
- `clickService(ouiaId: string): Promise<void>` - Clicks service by OUIA ID
- `clickServiceByPlatform(platformName: string): Promise<void>` - Clicks service by platform

### Constants

- `SEARCH_TIMEOUT` - Default timeout for search operations (10 seconds)

## License

ISC
