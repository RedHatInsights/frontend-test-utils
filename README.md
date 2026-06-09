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

## Security Scanning

This repository includes comprehensive security scanning to protect against supply chain attacks, CVE vulnerabilities, and accidental secret leakage.

### What Gets Scanned

- Detects malicious packages and supply chain attacks
- Monitors for unexpected network activity, shell access, and filesystem operations
- Analyzes dependency changes in PRs

**Trivy** - CVE, secrets, and misconfiguration scanning:
- Scans for known vulnerabilities (CVEs) in dependencies
- Detects accidentally committed secrets (API keys, tokens, credentials)
- Identifies security misconfigurations

### Running Scans Locally

```bash
npm run security:check
```

**Full scan (requires Docker for Trivy):**
```bash

# Trivy scan (via Docker)
docker run --rm -v "$(pwd):/src" aquasec/trivy fs \
  --scanners vuln,secret,misconfig \
  --severity CRITICAL,HIGH \
  /src
```

### CI/CD Integration

**Pull Request Checks:**
- Security scans run in parallel with builds on every PR
- Blocks on CRITICAL and HIGH severity findings only

**Pre-Publish Gate:**
- Additional security scan runs before npm publish
- Scans built packages in `dist/` for leaked secrets
- Prevents publishing compromised packages

### Handling Security Findings

1. Review the findings in the CI job logs
2. Investigate the flagged package - is it necessary?
3. Options:
   - Remove the package and find an alternative
   - If it's a false positive, document and create an exemption
   - Contact the package maintainer if behavior seems legitimate

**If Trivy finds a CVE:**
1. Update the vulnerable dependency:
   ```bash
   npm update <package-name>
   ```
2. If no fix is available:
   - Assess the risk (is the vulnerable code path used?)
   - Document accepted risk in `.trivyignore` with expiration date
   - Monitor for future updates

**If Trivy detects a secret in dist/:**
1. Identify how the secret got bundled (check build logs)
2. Move the secret to an environment variable
3. Add the secret pattern to `.gitignore` if needed
4. Re-trigger the release after fixing

### Exemptions and False Positives

**Trivy exemptions** - Add to `.trivyignore`:
```
# CVE-2024-12345  # Dev dependency only, not in production - expires 2026-09-01
```


### Troubleshooting

- Check if your npm token has the correct permissions

**Trivy fails to install:**
- The CI uses APT package installation (Ubuntu)
- For local use, Docker is the easiest option
- See [Trivy installation docs](https://aquasecurity.github.io/trivy/latest/getting-started/installation/) for alternatives

**False positive secrets detected:**
- Check if the "secret" is actually test data or example code
- Add to `.trivyignore` with clear justification
- Consider using more obvious fake values (e.g., `sk_test_XXXXX` vs real-looking tokens)

**Security job slowing down CI:**
- Security scans run in parallel with builds (~3-5 min total)
- This is intentional - security is part of the development workflow
- Findings are cached to speed up subsequent runs

### Security Policy

- **Severity thresholds**: CI blocks on CRITICAL and HIGH only
- **Scan frequency**: Every PR and before every publish
- **Exemption review**: Security exemptions expire and must be renewed
- **Incident response**: Critical findings block deployment until resolved

For questions about security findings or policies, open an issue or contact the maintainers.

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
