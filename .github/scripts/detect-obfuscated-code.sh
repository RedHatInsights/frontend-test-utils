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
  # Count consecutive hex values in a single line
  while IFS=: read -r line_num line_content; do
    # Count 0x patterns in this line
    hex_count=$(echo "$line_content" | grep -o "0x[0-9a-fA-F]\+" | wc -l | tr -d ' ')
    if [ "$hex_count" -gt 20 ]; then
      context=$(echo "$line_content" | cut -c1-80)
      report_finding "HIGH" "$file" "$line_num" "Line contains $hex_count hex values (potential obfuscation)" "$context"
    fi
  done < <(grep -n "0x[0-9a-fA-F]" "$file" 2>/dev/null || true)
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
  while IFS=: read -r line_num line_content; do
    # Count commas in fromCharCode call to estimate number of arguments
    char_count=$(echo "$line_content" | grep -oE "String\.fromCharCode\([^)]+\)" | tr ',' '\n' | wc -l | tr -d ' ')
    if [ "$char_count" -gt 20 ]; then
      context=$(echo "$line_content" | cut -c1-80)
      report_finding "HIGH" "$file" "$line_num" "String.fromCharCode with $char_count+ arguments (potential obfuscation)" "$context"
    fi
  done < <(grep -n "String\.fromCharCode" "$file" 2>/dev/null || true)
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
