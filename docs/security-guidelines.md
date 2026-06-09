# Security Guidelines

Security considerations for test utilities that handle authentication credentials and SSO flows.

## Credential Handling

### Environment Variables

Authentication credentials are passed via environment variables (`E2E_USER`, `E2E_PASSWORD`). These must **never** be:

- Hardcoded in source code, tests, or configuration files
- Logged to stdout/stderr (even in debug mode)
- Included in error messages or stack traces
- Committed to the repository in any form

### Storage State Files

Playwright's `storageState` saves authenticated session data (cookies, localStorage) to disk. These files:

- Must be listed in `.gitignore` (the default path `playwright/.auth/` should be gitignored)
- Contain session tokens that grant access to Red Hat services
- Should be treated as sensitive data in CI/CD pipelines

## URL Validation

When processing URLs (e.g., in `isBlockedCookieConsentHost()`), always use `new URL()` for parsing and catch invalid URLs gracefully. Never use string matching or regex on raw URL strings for security-sensitive decisions like request blocking.

```typescript
// Correct
try {
  const parsed = new URL(url);
  return blockedHosts.has(parsed.hostname);
} catch {
  return false; // invalid URL, don't block
}
```

## Request Interception

The `page.route()` pattern used for cookie consent blocking intercepts **all** page requests. When adding new route handlers:

- Use an allowlist approach (block specific known hosts) rather than a denylist
- Never abort `document` type requests — this breaks page navigation
- Validate that the host list is up to date with the actual third-party services used

## npm Publishing

- Packages are published with npm provenance (OIDC-based trusted publishing) — no manual tokens stored
- The `@redhat-cloud-services` npm scope requires organization membership
- GitHub Actions `id-token: write` permission is required for provenance signing

## Dependency Management

- Playwright is a `peerDependency`, not a direct dependency — consumers control the version
- Keep dependencies minimal to reduce supply chain attack surface
- Review dependency updates for security advisories before merging
