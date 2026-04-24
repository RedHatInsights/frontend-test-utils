@AGENTS.md

## Build Commands

```bash
# Install dependencies
npm install

# Build all packages
npm run build

# Build specific package
npx nx build playwright-test-auth

# Build only affected packages
npm run build:affected
```

## Verification

After making changes, always run:

```bash
# Build to verify TypeScript compilation
npm run build

# Verify build output exists
ls dist/packages/playwright-test-auth/src/index.js
```

There are currently no unit tests in the repo. If adding tests, use:

```bash
npm test               # Run all tests
npm run test:affected  # Run affected tests only
```

## CI Checks

PRs trigger these checks (`.github/workflows/ci.yml`):

1. **commitlint** — validates conventional commit messages
2. **build** — runs `npm ci && npm run build` and verifies output files exist

Ensure commit messages follow `<type>(<scope>): <description>` format with a valid scope from `.commitlintrc.json`.
