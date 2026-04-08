# Publishing Guide

This repository uses automated releases powered by NX and conventional commits. Packages are automatically published to npm when changes are merged to the master branch.

## How Automated Releases Work

### 1. Commit with Conventional Format

Use conventional commit messages to describe your changes:

```bash
# Feature (minor version bump: 1.0.0 → 1.1.0)
feat(playwright-test-auth): add support for custom timeout configuration

# Bug fix (patch version bump: 1.0.0 → 1.0.1)
fix(playwright-test-auth): properly validate URLs in cookie blocking

# Performance improvement (patch version bump)
perf(playwright-test-auth): optimize login flow

# Breaking change (major version bump: 1.0.0 → 2.0.0)
feat(playwright-test-auth)!: redesign authentication API

BREAKING CHANGE: The login() function signature has changed
```

### 2. Create Pull Request

Open a PR with your changes. The CI workflow will:
- Validate commit messages using commitlint
- Run builds and tests
- Verify all checks pass

### 3. Merge to Master

When your PR is merged, the release workflow automatically:
1. Analyzes conventional commits since last release
2. Determines version bump (major/minor/patch)
3. Updates package versions in package.json
4. Generates/updates CHANGELOG.md
5. Builds packages with new versions
6. Publishes to npm with provenance
7. Creates GitHub releases with changelogs

**Note:** Version bumps and changelogs are NOT committed back to the repository due to protected branch restrictions. Versions are tracked in the npm registry.

## Conventional Commit Format

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### Types

- `feat:` - New feature (minor bump)
- `fix:` - Bug fix (patch bump)
- `perf:` - Performance improvement (patch bump)
- `docs:` - Documentation only
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes

### Scopes

Use package names as scopes:
- `playwright-test-auth`
- `release`
- `ci`
- `deps`

### Breaking Changes

Indicate breaking changes with `!` or `BREAKING CHANGE:` footer:

```bash
# Method 1: Use ! after type/scope
feat(playwright-test-auth)!: remove deprecated login method

# Method 2: Use BREAKING CHANGE footer
feat(playwright-test-auth): redesign authentication API

BREAKING CHANGE: The login() function now requires an options object
instead of individual parameters.
```

## Setup (One-time)

### npm Trusted Publishing (OIDC)

This repository uses npm's trusted publishing feature, which doesn't require manual token management.

#### 1. Configure npm Organization

The `@redhat-cloud-services` npm organization must be configured to trust this GitHub repository.

1. Log in to [npmjs.com](https://www.npmjs.com)
2. Go to the organization settings
3. Navigate to **Publishing Access** → **GitHub Actions**
4. Add this repository: `RedHatInsights/frontend-test-utils`

#### 2. Verify Permissions

Ensure you have publish permissions for `@redhat-cloud-services` npm organization.

## Version Resolution

Current versions are tracked in the npm registry (not git tags). When determining the next version:

1. NX queries npm for the current published version
2. Analyzes commits since that version
3. Determines the appropriate bump based on conventional commits
4. Publishes the new version

## Manual Publishing (Fallback)

If you need to publish manually:

```bash
# Build the package
npx nx build playwright-test-auth

# Navigate to dist directory
cd dist/packages/playwright-test-auth

# Publish to npm
npm publish --access public
```

**Note:** Manual publishing won't create GitHub releases or update changelogs.

## Troubleshooting

### Commit messages failing validation

If commitlint rejects your commits:

```bash
# View the error message
# Common issues:
# - Missing type (feat, fix, etc.)
# - Invalid scope
# - Subject too short

# Fix with:
git commit --amend
```

### No version bump

If commits don't trigger a release:
- Ensure commits use conventional format
- Types like `docs:`, `style:`, `chore:` don't trigger releases by default
- Use `feat:` for new features or `fix:` for bug fixes

### Release failed

Check the GitHub Actions logs:
1. Go to **Actions** tab
2. Find the failed release workflow
3. Review the error messages

Common issues:
- Build failures: Fix build errors and create a new PR
- npm permissions: Verify organization access
- Network issues: Workflow will retry on next push

### Check published version

Verify the package on npm:

```bash
npm view @redhat-cloud-services/playwright-test-auth

# Or install and test
npm install @redhat-cloud-services/playwright-test-auth
```

## Protected Branch Compatibility

The release process is designed to work with protected branches:

- ✅ No git commits pushed back to master
- ✅ No git tags created in repository
- ✅ Versions tracked in npm registry
- ✅ GitHub releases still created
- ✅ Changelogs still generated

This ensures the master branch can have strict protection rules while still enabling automated releases.
