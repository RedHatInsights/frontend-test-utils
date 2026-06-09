#!/bin/bash
# Detect potentially obfuscated or malicious code patterns
# Exit code 0 = clean, 1 = suspicious patterns found

set -e

SUSPICIOUS_FOUND=0
REPORT_FILE=$(mktemp)

echo "Scanning for obfuscated code patterns..."
echo ""

# Function to report findings
report_finding() {
  local severity=$1
  local file=$2
  local line=$3
  local pattern=$4
  local context=$5

  SUSPICIOUS_FOUND=1
  echo "[$severity] $file:$line" | tee -a "$REPORT_FILE"
  echo "  Pattern: $pattern" | tee -a "$REPORT_FILE"
  echo "  Context: $context..." | tee -a "$REPORT_FILE"
  echo "" | tee -a "$REPORT_FILE"
}

# 1. Large hex arrays (potential shellcode)
echo "Checking for large hex arrays..."
find packages -type f \( -name "*.ts" -o -name "*.js" \) ! -path "*/node_modules/*" ! -path "*/dist/*" -print0 2>/dev/null | while IFS= read -r -d '' file; do
  # Count total hex values in the entire file (handles multi-line arrays)
  total_hex=$(grep -o "0x[0-9a-fA-F]\+" "$file" 2>/dev/null | wc -l | tr -d ' ')

  if [ "$total_hex" -gt 20 ]; then
    # Find the first line with hex values for context
    first_hex_line=$(grep -n "0x[0-9a-fA-F]" "$file" 2>/dev/null | head -1 || true)
    if [ -n "$first_hex_line" ]; then
      line_num=$(echo "$first_hex_line" | cut -d: -f1)
      context=$(echo "$first_hex_line" | cut -d: -f2- | cut -c1-80)
      report_finding "HIGH" "$file" "$line_num" "File contains $total_hex hex values (potential shellcode/obfuscation)" "$context"
    fi
  fi
done

# 2. Large base64 strings
echo "Checking for large base64 strings..."
find packages -type f \( -name "*.ts" -o -name "*.js" \) ! -path "*/node_modules/*" ! -path "*/dist/*" -print0 2>/dev/null | while IFS= read -r -d '' file; do
  while IFS=: read -r line_num line_content; do
    # Look for strings that are mostly base64 characters and very long
    if echo "$line_content" | grep -qE "['\"][A-Za-z0-9+/]{200,}={0,2}['\"]"; then
      context=$(echo "$line_content" | cut -c1-80)
      report_finding "HIGH" "$file" "$line_num" "Large base64-like string detected" "$context"
    fi
  done < <(grep -nE "['\"][A-Za-z0-9+/]{200,}" "$file" 2>/dev/null || true)
done

# 3. Eval and Function constructor
echo "Checking for dynamic code execution..."
find packages -type f \( -name "*.ts" -o -name "*.js" \) ! -path "*/node_modules/*" ! -path "*/dist/*" -print0 2>/dev/null | while IFS= read -r -d '' file; do
  # Check for eval()
  while IFS=: read -r line_num line_content; do
    # Skip comments
    if echo "$line_content" | grep -qE "^\s*(//|/\*|\*)"; then
      continue
    fi
    context=$(echo "$line_content" | cut -c1-80)
    report_finding "CRITICAL" "$file" "$line_num" "eval() usage detected" "$context"
  done < <(grep -nE "\beval\s*\(" "$file" 2>/dev/null || true)

  # Check for Function constructor
  while IFS=: read -r line_num line_content; do
    if echo "$line_content" | grep -qE "^\s*(//|/\*|\*)"; then
      continue
    fi
    context=$(echo "$line_content" | cut -c1-80)
    report_finding "CRITICAL" "$file" "$line_num" "Function constructor usage detected" "$context"
  done < <(grep -nE "new\s+Function\s*\(" "$file" 2>/dev/null || true)
done

# 4. String.fromCharCode with many arguments
echo "Checking for character code obfuscation..."
find packages -type f \( -name "*.ts" -o -name "*.js" \) ! -path "*/node_modules/*" ! -path "*/dist/*" -print0 2>/dev/null | while IFS= read -r -d '' file; do
  # Check if file contains String.fromCharCode
  if grep -q "String\.fromCharCode" "$file" 2>/dev/null; then
    # Read file content, remove newlines to handle multi-line calls, then count commas
    file_content=$(cat "$file" | tr '\n' ' ')

    # Extract all fromCharCode calls and count arguments (commas + 1)
    while read -r call; do
      if [ -n "$call" ]; then
        comma_count=$(echo "$call" | tr -cd ',' | wc -c | tr -d ' ')
        arg_count=$((comma_count + 1))

        if [ "$arg_count" -gt 20 ]; then
          # Find line number of String.fromCharCode
          line_num=$(grep -n "String\.fromCharCode" "$file" 2>/dev/null | head -1 | cut -d: -f1)
          context=$(grep "String\.fromCharCode" "$file" 2>/dev/null | head -1 | cut -c1-80)
          report_finding "HIGH" "$file" "$line_num" "String.fromCharCode with $arg_count arguments (potential obfuscation)" "$context"
          break
        fi
      fi
    done < <(echo "$file_content" | grep -oE "String\.fromCharCode\([^)]+\)" || true)
  fi
done

# 5. Very long lines in non-minified files
echo "Checking for suspicious minification..."
find packages -type f \( -name "*.ts" -o -name "*.js" \) ! -path "*/node_modules/*" ! -path "*/dist/*" ! -name "*.min.js" ! -name "*.bundle.js" -print0 2>/dev/null | while IFS= read -r -d '' file; do
  while IFS=: read -r line_num line_content; do
    # Skip comments
    if echo "$line_content" | grep -qE "^\s*(//|/\*|\*)"; then
      continue
    fi

    line_length=${#line_content}
    if [ "$line_length" -gt 500 ]; then
      # Check if it contains many semicolons (typical of minified code)
      semicolon_count=$(echo "$line_content" | tr -cd ';' | wc -c | tr -d ' ')
      if [ "$semicolon_count" -gt 5 ]; then
        context=$(echo "$line_content" | cut -c1-80)
        report_finding "MEDIUM" "$file" "$line_num" "Suspiciously long line ($line_length chars, $semicolon_count semicolons) in source file" "$context"
      fi
    fi
  done < <(awk 'length($0) > 500 { print NR":"$0 }' "$file" 2>/dev/null || true)
done

# Summary
echo "=========================================="
# Check if report file has any content (more reliable than variable in subshells)
if [ -s "$REPORT_FILE" ]; then
  echo "SUSPICIOUS CODE PATTERNS DETECTED"
  echo "=========================================="
  cat "$REPORT_FILE"
  echo ""
  echo "Review the findings above. If these are legitimate,"
  echo "they can be documented and approved by security reviewers."
  rm -f "$REPORT_FILE"
  exit 1
else
  echo "✓ No suspicious code patterns detected."
  echo "=========================================="
  rm -f "$REPORT_FILE"
  exit 0
fi
