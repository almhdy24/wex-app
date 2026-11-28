#!/usr/bin/env bash
# UI rule checker (bash + ripgrep). Prints file:line for every violation, exits non-zero if any.
# Usage: tools/verify_ui.sh [APP_DIR] [WEB_DIR]
#   APP_DIR defaults to this repo (lib/). WEB_DIR (optional) = web/admin source (src/) for CSS/TSX rules.
# Allowlist: tools/verify_allowlist.txt, lines "path-substring|rule|reason".
set -u
ROOT="$(cd "${1:-$(dirname "$0")/..}" && pwd)"
WEB="${2:-}"
ALLOW="$ROOT/tools/verify_allowlist.txt"
FAIL=0
VIOLET='3E4EE8|3340D4|6A5CF0|5A54E6|2E3BC4'

allowed() { # $1=file $2=rule
  [ -f "$ALLOW" ] || return 1
  while IFS='|' read -r p r _; do
    [ -z "${p// }" ] && continue
    case "$p" in \#*) continue;; esac
    if [[ "$1" == *"$p"* && "$2" == "$r" ]]; then return 0; fi
  done < "$ALLOW"
  return 1
}

# report RULE MESSAGE  (reads "file:line:text" lines from stdin)
report() {
  local rule="$1" msg="$2" n=0
  while IFS= read -r line; do
    f="${line%%:*}"
    if allowed "$f" "$rule"; then continue; fi
    echo "VIOLATION [$rule] $msg -> $line"
    n=$((n+1))
  done
  [ "$n" -gt 0 ] && FAIL=1
  return 0
}

DART_DIRS=("$ROOT/lib")
[ -d "$ROOT/lib" ] || { echo "no lib/ under $ROOT"; exit 2; }
GEN="colors.g.dart"

# a) violet palette (case-insensitive, also 0xFF forms) in app (+web)
report violet "old violet hex" < <(rg -n -i --no-heading -g '!*.g.dart' -g '!*.png' -g '!*.ttf' -e "($VIOLET)" "$ROOT/lib" "$ROOT/tokens" 2>/dev/null)
[ -n "$WEB" ] && report violet "old violet hex (web)" < <(rg -n -i --no-heading -g '*.{css,js,jsx,ts,tsx,html,json}' -e "($VIOLET)" "$WEB" 2>/dev/null)

# b) Flutter rules
report flutter-colors "Colors.* other than Colors.transparent" < <(rg -n -P --no-heading -g '*.dart' '(?<![A-Za-z])Colors\.(?!transparent\b)\w+' "$ROOT/lib")
report flutter-color-literal "Color literal outside $GEN" < <(rg -n -P --no-heading -g '*.dart' -g "!$GEN" '\bColor\(0x|Color\.fromRGBO|Color\.fromARGB' "$ROOT/lib")
report flutter-hex "hex literal outside $GEN" < <(rg -n -P --no-heading -g '*.dart' -g "!$GEN" '(?<![A-Za-z0-9_])#[0-9A-Fa-f]{6}\b|0xFF[0-9A-Fa-f]{6}\b' "$ROOT/lib")
report blur "BackdropFilter / ImageFilter.blur" < <(rg -n --no-heading -g '*.dart' -e 'BackdropFilter|ImageFilter\.blur' "$ROOT/lib")
report nav "Material NavigationBar" < <(rg -n -P --no-heading -g '*.dart' '\bNavigationBar\(' "$ROOT/lib")
report gradient "gradient outside lib/ui/gradients.dart" < <(rg -n -P --no-heading -g '*.dart' -g '!gradients.dart' '(Linear|Radial|Sweep)Gradient' "$ROOT/lib")
report shadow "BoxShadow outside lib/ui/elevation.dart" < <(rg -n -P --no-heading -g '*.dart' -g '!elevation.dart' '\bBoxShadow\(' "$ROOT/lib")
report font "hardcoded fontFamily outside the theme" < <(rg -n -P --no-heading -g '*.dart' -g '!theme.dart' "fontFamily\s*:|'Tajawal'|\"Tajawal\"" "$ROOT/lib")
report emoji "emoji character" < <(rg -n -P --no-heading -g '*.{dart,tsx,jsx,css,js}' '[\x{1F300}-\x{1FAFF}\x{2600}-\x{27BF}\x{1F000}-\x{1F2FF}]' "$ROOT/lib" ${WEB:+"$WEB"} 2>/dev/null)

# c) web / admin CSS
if [ -n "$WEB" ]; then
  report css-gradient "gradient outside --hero-gradient" < <(rg -n -P --no-heading -g '*.css' -g '!tokens*.css' 'linear-gradient|radial-gradient|conic-gradient' "$WEB" | grep -v 'var(--hero-gradient)')
  report css-blur "backdrop-filter" < <(rg -n -P --no-heading -g '*.css' 'backdrop-filter' "$WEB")
  report css-shadow "box-shadow other than the shadow token" < <(rg -n -P --no-heading -g '*.css' -g '!tokens*.css' 'box-shadow\s*:(?!\s*(none|var\(--shadow))' "$WEB")
  report css-physical "physical left/right property (use logical)" < <(rg -n -P --no-heading -g '*.css' '(^|[;{\s])(margin-left|margin-right|padding-left|padding-right|border-left|border-right)\s*:|(^|[;{\s])(left|right)\s*:\s*[-\d.]' "$WEB")
fi

# d) fixed heights directly wrapping Text (review each hit; allowlist when intentional)
report fixed-height-text "fixed height wrapping Text (use minHeight/padding)" < <(rg -n -U -P --no-heading -g '*.dart' 'SizedBox\(\s*(width:\s*[^,]+,\s*)?height:\s*\d+(\.\d+)?,\s*child:\s*Text\(' "$ROOT/lib")

# e) every scroll view in features/ must be inside an AppScaffold screen (file imports it)
for f in $(rg -l --no-heading -P '\b(ListView|CustomScrollView|SingleChildScrollView)\b' "$ROOT/lib/features" 2>/dev/null); do
  if ! rg -q "ui/app_scaffold.dart" "$f"; then
    if ! allowed "$f" scroll-inset; then echo "VIOLATION [scroll-inset] scroll view without AppScaffold inset -> $f"; FAIL=1; fi
  fi
done

if [ "$FAIL" -eq 0 ]; then echo "verify_ui: OK (no violations)"; fi
exit "$FAIL"
