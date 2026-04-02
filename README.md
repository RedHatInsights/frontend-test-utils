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

- Node.js (v18 or higher recommended)
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

Build a specific package:
```bash
npm run build:playwright-test-auth
```

### Publishing

Packages are automatically published to npm via GitHub Actions when you create a release.

**To publish a new version:**

1. Create a git tag with format `<package-name>@<version>`:
   ```bash
   git tag playwright-test-auth@1.0.0
   git push origin playwright-test-auth@1.0.0
   ```

2. Create a GitHub Release from that tag

3. The package will be automatically built and published to npm

**Manual publishing:**

If you need to publish manually:
```bash
npm run build:playwright-test-auth
cd dist/packages/playwright-test-auth
npm publish
```

See [Publishing Guide](./.github/PUBLISHING.md) for detailed instructions.

## Adding New Packages

To add a new testing utilities package:

1. Create a new directory under `packages/`
2. Add the package configuration files (package.json, tsconfig.json, project.json)
3. Add the package path to `tsconfig.base.json`
4. Add build and publish scripts to root `package.json`

## License

ISC
