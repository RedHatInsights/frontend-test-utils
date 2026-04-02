# Publishing Guide

This repository uses GitHub Actions to automatically publish packages to npm.

## Setup (One-time)

### 1. Create an npm Access Token

1. Log in to [npmjs.com](https://www.npmjs.com)
2. Go to **Access Tokens** in your account settings
3. Click **Generate New Token** → **Classic Token**
4. Select **Automation** type (recommended for CI/CD)
5. Copy the token

### 2. Add Token to GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `NPM_TOKEN`
5. Value: Paste your npm token
6. Click **Add secret**

### 3. Join the npm Organization (if applicable)

If publishing to `@redhat-cloud-services` scope, make sure you have publish permissions for that npm organization.

## Publishing a Package

### Method 1: GitHub Releases (Recommended)

1. Create a git tag with the format: `<package-name>@<version>`
   ```bash
   git tag test-auth@1.0.0
   git push origin test-auth@1.0.0
   ```

2. Create a GitHub Release from that tag
   - Go to **Releases** → **Create a new release**
   - Select the tag you just created
   - Add release notes describing changes
   - Click **Publish release**

3. The publish workflow will automatically run and publish to npm

### Method 2: Manual Workflow Dispatch

1. Go to **Actions** → **Publish Packages**
2. Click **Run workflow**
3. Enter:
   - **Package**: `test-auth`
   - **Tag**: `latest` (or `beta`, `next`, etc.)
4. Click **Run workflow**

This is useful for:
- Publishing beta versions
- Re-publishing after a failed run
- Testing the publish workflow

## Version Naming Convention

Use semantic versioning with the package name prefix:

- `test-auth@1.0.0` - Major release
- `test-auth@1.1.0` - Minor release (new features)
- `test-auth@1.0.1` - Patch release (bug fixes)
- `test-auth@1.0.0-beta.1` - Pre-release

## Publishing Beta Versions

For testing before stable release:

```bash
# Create beta tag
git tag test-auth@1.0.0-beta.1
git push origin test-auth@1.0.0-beta.1

# Create release and mark as "pre-release"
```

Or use manual workflow dispatch with tag: `beta`

Install with:
```bash
npm install @redhat-cloud-services/playwright-test-auth@beta
```

## Troubleshooting

### "Package already exists"

You can't republish the same version. Increment the version number.

### "Not authorized"

Check that:
1. `NPM_TOKEN` secret is set correctly
2. Your npm account has publish permissions for the `@redhat-cloud-services` scope
3. The token hasn't expired

### Build fails

Check the CI workflow runs to see build errors before publishing.

## After Publishing

Verify the package:
```bash
npm view @redhat-cloud-services/playwright-test-auth
```

Install and test:
```bash
npm install @redhat-cloud-services/playwright-test-auth
```
