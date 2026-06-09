# Testing Guidelines

Guidelines for developing and maintaining test utilities in the frontend-test-utils monorepo.

## Package Architecture

- Each package in `packages/` is an independent npm library published under the `@redhat-cloud-services` scope
- Packages are consumed by downstream HCC frontend repos as dev dependencies
- Utilities must work in Playwright global setup files **and** individual test files

## Playwright Utilities

### Import Strategy

Global setup files **must** import from `playwright` (core), not `@playwright/test`. Using `@playwright/test` in global setup causes `"Requiring @playwright/test second time"` errors. This is a hard Playwright constraint.

```typescript
// Correct - for global setup files
import { chromium } from 'playwright';
import type { FullConfig } from '@playwright/test'; // types are OK

// Wrong - causes runtime error in global setup
import { chromium } from '@playwright/test';
```

### ESM Module Resolution

All relative imports must include `.js` extensions for proper ESM resolution:

```typescript
import { login } from './auth.js';     // correct
import { login } from './auth';        // wrong
```

### Error Handling Pattern

Auth utilities use standard `throw new Error()` instead of Playwright's `expect()` assertions. This keeps them safe for global setup usage (no dependency chain issues) while providing clear error messages:

- `'Proxy config incorrect - Lockdown page detected'`
- `'Invalid login credentials'`
- `'Login failed - user greeting not displayed'`

Prefer descriptive error messages that help diagnose the failure without needing to read the source.

### Cookie Consent Blocking

`disableCookiePrompt()` uses `page.route()` to block TrustArc hosts. Note: subsequent `page.route()` calls can override this handler. Document this ordering requirement in any new utility that also uses route interception.

## Adding New Packages

1. Create the package directory under `packages/<name>/`
2. Add `project.json` with NX project configuration (use `playwright-test-auth` as reference)
3. Add `package.json` with `@redhat-cloud-services/<name>` naming
4. Add the package scope to `.commitlintrc.json` `scope-enum` array
5. Add `tsconfig.json` and `tsconfig.lib.json` (extend from `../../tsconfig.base.json`)
6. Build output goes to `dist/packages/<name>/`
7. Add a `README.md` inside the package — it gets copied to the dist via the `assets` config in `project.json`

## TypeScript

- Target: ES2020
- Module: ESNext with bundler resolution
- Strict mode is not enforced at the base level — individual packages may opt in
- Declaration files (`.d.ts`) are generated during build for consumers
- Path aliases defined in `tsconfig.base.json` for cross-package imports during development

## Build Verification

CI verifies that all expected output files exist after build:

```
dist/packages/<name>/src/index.js
dist/packages/<name>/src/<module>.js
dist/packages/<name>/package.json
```

When adding new source files to a package, ensure the CI verification step in `.github/workflows/ci.yml` is updated if the file is a primary export.
