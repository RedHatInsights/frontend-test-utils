# Agent Guide — frontend-test-utils

This document provides AI agents with the context and conventions needed to work effectively in this repository.

## Project Overview

An NX-managed monorepo providing reusable testing utilities for Red Hat Hybrid Cloud Console (HCC) frontend applications. Packages are published to npm under the `@redhat-cloud-services` scope.

**Current packages:**

| Package | Purpose |
|---------|---------|
| `@redhat-cloud-services/playwright-test-auth` | Red Hat SSO authentication helpers for Playwright e2e tests |

## Documentation Index

| Document | Description |
|----------|-------------|
| [docs/testing-guidelines.md](docs/testing-guidelines.md) | Package architecture, Playwright patterns, adding new packages |
| [docs/security-guidelines.md](docs/security-guidelines.md) | Credential handling, URL validation, publishing security |

## Repository Structure

```
frontend-test-utils/
  packages/                    # NX packages (each is a publishable npm library)
    playwright-test-auth/      # Playwright SSO auth utilities
      src/
        auth.ts                # login(), disableCookiePrompt()
        global-setup.ts        # Playwright globalSetup function
        index.ts               # Public API barrel export
      project.json             # NX project config (build, publish targets)
      package.json             # npm package metadata + peer deps
      tsconfig.json            # Package-level TS config
      README.md                # Package documentation (copied to dist)
  .github/
    workflows/ci.yml           # CI: commitlint, build, release
    actions/release/action.yml  # Composite action for NX release
    PUBLISHING.md              # Publishing guide
  nx.json                      # NX workspace config, release settings
  tsconfig.base.json           # Shared TypeScript configuration
  .commitlintrc.json           # Conventional commit rules + allowed scopes
```

## Conventions

### Commit Messages

This repo enforces [conventional commits](https://www.conventionalcommits.org/) via commitlint:

```
<type>(<scope>): <description>
```

**Allowed scopes** (defined in `.commitlintrc.json`):
- `playwright-test-auth` — changes to the playwright-test-auth package
- `release` — release-related changes
- `deps` — dependency updates
- `ci` — CI/CD changes

When adding a new package, add its name to the `scope-enum` in `.commitlintrc.json`.

**Release-triggering types**: `feat:` (minor), `fix:` (patch), `perf:` (patch). Other types (`docs:`, `chore:`, `refactor:`, `test:`, `style:`, `ci:`) do not trigger npm releases.

### Code Style

- TypeScript with ES2020 target and ESNext modules
- ESM imports with `.js` extensions on all relative imports
- Use `playwright` (core) imports in global setup files, not `@playwright/test`
- Export public API through barrel files (`index.ts`)
- JSDoc comments on all exported functions

### Naming

- Package directories: kebab-case under `packages/`
- npm scope: `@redhat-cloud-services/<package-name>`
- Source files: kebab-case `.ts` files
- Functions: camelCase
- Constants: UPPER_SNAKE_CASE

### Dependencies

- Playwright is a `peerDependency` — consumers control the version (minimum 1.40.0)
- Keep package dependencies minimal — these are lightweight utilities
- Dev dependencies belong in the root `package.json`
- Package-specific peer dependencies go in the package's own `package.json`

### Build and Release

- Build: `npm run build` (runs `nx run-many -t build`)
- Output: `dist/packages/<name>/`
- Releases are fully automated — merge to `master` triggers version bump, changelog, npm publish
- Version tracking uses git tags (`<package>@<version>`)
- npm publishing uses OIDC-based provenance (no tokens needed)

## Common Pitfalls

1. **Importing `@playwright/test` in global setup files** causes a runtime error. Use `playwright` core imports instead.
2. **Missing `.js` extensions** on relative imports breaks ESM resolution at runtime.
3. **Forgetting to update `.commitlintrc.json`** when adding a new package scope causes CI commit lint failures.
4. **Using `expect()` assertions in auth utilities** creates dependency chain issues in global setup. Use `throw new Error()` instead.
5. **`page.route()` ordering** — `disableCookiePrompt()` should be called last in setup because subsequent `page.route()` calls can override it.
