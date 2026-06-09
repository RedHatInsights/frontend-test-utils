# Security Scanning Scripts

## detect-obfuscated-code.sh

Scans source code for patterns commonly associated with obfuscated or malicious code.

### What It Detects

**CRITICAL Severity:**
- `eval()` usage - Dynamic code execution
- `new Function()` constructor - Runtime code generation

**HIGH Severity:**
- Large hex arrays (20+ consecutive `0x` values) - Potential shellcode
- Large base64 strings (200+ characters) - Encoded payloads
- `String.fromCharCode()` with many arguments - Character code obfuscation

**MEDIUM Severity:**
- Suspiciously long lines (500+ chars with 5+ semicolons) in source files - Hidden minified code

### Usage

**Local:**
```bash
.github/scripts/detect-obfuscated-code.sh
```

**CI:**
Automatically runs on every PR as part of the `verify-npm-package` job.

### Exit Codes

- `0` - No suspicious patterns detected
- `1` - Suspicious patterns found (blocks CI)

### Scope

Scans all `.ts` and `.js` files in `packages/` directory.
Excludes: `node_modules/`, `dist/`, `*.min.js`, `*.bundle.js`

### False Positives

If legitimate code triggers detection:

1. **Document the pattern** - Add comments explaining why the pattern is necessary
2. **Code review** - Ensure security team reviews and approves
3. **Refactor if possible** - Consider safer alternatives

**Do NOT create an allowlist without security team approval.**

### Examples

**Blocked patterns:**
```javascript
// CRITICAL: eval() usage
const result = eval(userInput);

// CRITICAL: Function constructor
const fn = new Function('x', 'return x * 2');

// HIGH: Large hex array (potential shellcode)
const data = [0x4d, 0x5a, 0x90, 0x00, 0x03, 0x00, /* ... 20+ more values ... */];

// HIGH: Base64 encoded payload
const payload = "VGhpc0lzQVZlcnlMb25nQmFzZTY0U3RyaW5nVGhhdE1pZ2h0Q29udGFpbk1hbGljaW91c0NvZGU...";

// HIGH: Character code obfuscation
const str = String.fromCharCode(72, 101, 108, 108, 111, /* ... 20+ more */);

// MEDIUM: Minified code in source file
const x=1;const y=2;const z=3;const a=4;const b=5;const c=6; // ... 500+ chars
```

**Allowed patterns:**
```javascript
// OK: Small arrays
const rgb = [0xff, 0x00, 0x00]; // Red color

// OK: Normal base64 usage with reasonable length
const icon = "data:image/png;base64,iVBORw0KGgo..."; // < 200 chars

// OK: No eval or Function constructor usage in legitimate code
```

### Integration with Security Scanning

This script works alongside:
- **Socket.dev** - Supply chain attack detection
- **Trivy** - CVE and secrets scanning
- **npm pack verification** - Publication security

Together these provide defense-in-depth against:
- Supply chain attacks
- Malicious dependencies
- Code injection
- Secrets leakage
