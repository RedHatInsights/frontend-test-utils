# frontend-test-utils

Reusable snippets of code for consumption in unit, integration, or e2e test pipelines.

This is an nx-managed monorepo containing npm packages with common testing utilities for frontend projects.

## Packages

### [@frontend-test-utils/test-auth](./packages/test-auth)

Reusable Red Hat SSO authentication utilities for Playwright e2e testing.

Features:
- Red Hat SSO login helpers
- Global setup for session reuse
- TrustArc cookie consent blocking
- Environment-based configuration

[View package documentation →](./packages/test-auth/README.md)

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
npm run build:test-auth
```

### Publishing

To publish a package to npm:

```bash
npm run publish:test-auth
```

**Note:** Make sure you're authenticated to npm and have the appropriate permissions.

## Adding New Packages

To add a new testing utilities package:

1. Create a new directory under `packages/`
2. Add the package configuration files (package.json, tsconfig.json, project.json)
3. Add the package path to `tsconfig.base.json`
4. Add build and publish scripts to root `package.json`

## License

ISC
