# frontend-test-utils

Reusable snippets of code for consumption in unit, integration, or e2e test pipelines.

This is an nx-managed monorepo containing npm packages with common testing utilities for frontend projects.

## Packages

### [@redhat-cloud-services/playwright-test-auth](./packages/playwright-test-auth)

Reusable Red Hat SSO authentication utilities for Playwright e2e testing.

Features:
- Red Hat SSO login helpers
- Global setup for session reuse
- TrustArc cookie consent blocking
- Environment-based configuration

[View package documentation →](./packages/playwright-test-auth/README.md)

## Development

### Prerequisites

- Node.js 20 or higher (required)
- npm

### Setup

```bash
npm install
```

### Building Packages

Build all packages:
```bash
npm run build
```

Build only packages affected by recent changes:
```bash
npm run build:affected
```

Build a specific package:
```bash
npx nx build playwright-test-auth
```

### Publishing

This repository uses automated releases powered by NX and conventional commits.

**How it works:**

1. **Commit with conventional format** - Use conventional commit messages (e.g., `feat:`, `fix:`, `chore:`)
2. **Merge to master** - When your PR is merged, GitHub Actions automatically:
   - Analyzes commits to determine version bump (major/minor/patch)
   - Updates package versions and changelogs
   - Builds packages
   - Publishes to npm with provenance
   - Creates GitHub releases

**Commit message format:**

```bash
<type>(<scope>): <description>

# Examples:
feat(playwright-test-auth): add support for custom login flows
fix(playwright-test-auth): properly validate URLs in cookie blocking
chore(ci): update workflow permissions
```

**Types that trigger releases:**
- `feat:` - New feature (minor version bump)
- `fix:` - Bug fix (patch version bump)
- `perf:` - Performance improvement (patch version bump)

**Breaking changes** trigger major version bumps:
```bash
feat(playwright-test-auth)!: remove deprecated login method

BREAKING CHANGE: The old login() function has been removed
```

**Manual publishing:**

If needed, you can publish manually from the built package:
```bash
# Build the package
npx nx build playwright-test-auth

# Publish from the dist directory
cd dist/packages/playwright-test-auth
npm publish --access public
```

See [Publishing Guide](./.github/PUBLISHING.md) for setup instructions and troubleshooting.

## Adding New Packages

To add a new testing utilities package:

1. Create a new directory under `packages/`
2. Add the package configuration files (package.json, tsconfig.json, project.json)
3. Add the package path to `tsconfig.base.json`
4. Add the package name to the `scope-enum` in `.commitlintrc.json`
5. NX will automatically detect and manage the new package

See [testing guidelines](./docs/testing-guidelines.md) for detailed package setup instructions.

## Documentation

- [AGENTS.md](./AGENTS.md) — AI agent onboarding guide and repo conventions
- [docs/testing-guidelines.md](./docs/testing-guidelines.md) — Testing patterns and package development
- [docs/security-guidelines.md](./docs/security-guidelines.md) — Security considerations
- [Publishing Guide](./.github/PUBLISHING.md) — Release process and troubleshooting

## License

ISC
