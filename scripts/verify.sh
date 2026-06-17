#!/bin/bash
# Dotfiles Verify — diagnostisk sjekk av oppsett
# Kjøres etter setup eller manuelt for å bekrefte at alt er korrekt.

set -o pipefail

DOTFILES="$HOME/dotfiles"
ISSUES=0

# --------------------------------------------------------------------------
# Farger og hjelpefunksjoner
# --------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

pass() {
  echo -e "  ${GREEN}✓${RESET}  $1"
}

fail() {
  echo -e "  ${RED}✗${RESET}  $1"
  ISSUES=$((ISSUES + 1))
}

warn() {
  echo -e "  ${YELLOW}!${RESET}  $1"
}

header() {
  echo ""
  echo -e "${BOLD}$1${RESET}"
}

# --------------------------------------------------------------------------
# 1. Symlinks
# --------------------------------------------------------------------------

header "Symlinks"

while read -r type src dest; do
  src="$DOTFILES/$src"
  dest=$(eval echo "$dest")

  if [ ! -e "$dest" ] && [ ! -L "$dest" ]; then
    fail "$dest (mangler)"
  elif [ ! -L "$dest" ]; then
    fail "$dest (eksisterer men er ikke en symlink)"
  else
    actual=$(readlink "$dest")
    if [ "$actual" != "$src" ]; then
      fail "$dest -> $actual (forventet $src)"
    else
      pass "$dest"
    fi
  fi
done < <(grep -v '^\s*#' "$DOTFILES/symlinks.conf" | grep -v '^\s*$')

# Zen Browser (spesialtilfelle)
ZEN_PROFILE=$(find "$HOME/Library/Application Support/zen/Profiles" \
  -maxdepth 1 -name "*.Default (release)" -type d 2>/dev/null | head -1)
if [ -n "$ZEN_PROFILE" ]; then
  zen_dest="$ZEN_PROFILE/user.js"
  zen_src="$DOTFILES/zen/user.js"
  if [ ! -L "$zen_dest" ]; then
    fail "$zen_dest (mangler eller ikke symlink)"
  else
    actual=$(readlink "$zen_dest")
    if [ "$actual" != "$zen_src" ]; then
      fail "$zen_dest -> $actual (forventet $zen_src)"
    else
      pass "$zen_dest"
    fi
  fi
else
  warn "Zen Browser: profil ikke funnet, hopper over"
fi

# --------------------------------------------------------------------------
# 2. Tools (fra Brewfile [verify]-annotasjoner)
# --------------------------------------------------------------------------

header "Tools"

while IFS= read -r line; do
  # Hent pakkenavn fra brew "pakke" eller brew "tap/pakke"
  pkg=$(echo "$line" | sed -n 's/^brew "\([^"]*\)".*/\1/p')
  # Fjern eventuell tap-prefix for visning
  pkg_short="${pkg##*/}"

  if echo "$line" | grep -q '\[verify cmd:[^]]*\]'; then
    # [verify cmd:<cmd>] — sjekk spesifikt kommandonavn
    cmd=$(echo "$line" | sed -n 's/.*\[verify cmd:\([^]]*\)\].*/\1/p')
    if command -v "$cmd" &>/dev/null; then
      pass "$pkg_short ($cmd)"
    else
      fail "$pkg_short ($cmd ikke i PATH)"
    fi
  elif echo "$line" | grep -q '\[verify\]'; then
    # [verify] — sjekk pakkenavn som kommando
    if command -v "$pkg_short" &>/dev/null; then
      pass "$pkg_short"
    else
      fail "$pkg_short (ikke i PATH)"
    fi
  fi
done < <(grep '\[verify' "$DOTFILES/Brewfile")

# --------------------------------------------------------------------------
# 3. Zsh-plugins (fra Brewfile [verify zsh-plugin]-annotasjoner)
# --------------------------------------------------------------------------

header "Zsh plugins"

BREW_PREFIX=$(brew --prefix)

while IFS= read -r line; do
  pkg=$(echo "$line" | sed -n 's/^brew "\([^"]*\)".*/\1/p')
  pkg_short="${pkg##*/}"
  plugin_file="$BREW_PREFIX/share/$pkg_short/$pkg_short.zsh"

  if [ -f "$plugin_file" ]; then
    pass "$pkg_short"
  else
    fail "$pkg_short ($plugin_file mangler)"
  fi
done < <(grep '\[verify zsh-plugin\]' "$DOTFILES/Brewfile")

# --------------------------------------------------------------------------
# 4. Zsh-moduler
# --------------------------------------------------------------------------

header "Zsh modules"

zsh_modules=(options completions environment aliases lazy-loaders tools plugins)
for mod in "${zsh_modules[@]}"; do
  if [ -f "$DOTFILES/zsh/$mod.sh" ]; then
    pass "zsh/$mod.sh"
  else
    fail "zsh/$mod.sh (mangler)"
  fi
done

# Sjekk at functions/ ikke er tom
func_count=$(find "$DOTFILES/zsh/functions" -name "*.sh" 2>/dev/null | wc -l | tr -d ' ')
if [ "$func_count" -gt 0 ]; then
  pass "zsh/functions/ ($func_count funksjoner)"
else
  fail "zsh/functions/ (tom eller mangler)"
fi

# --------------------------------------------------------------------------
# 5. Secrets
# --------------------------------------------------------------------------

header "Secrets"

if [ -d ~/.secrets ]; then
  mode=$(stat -f "%Lp" ~/.secrets 2>/dev/null)
  if [ "$mode" = "700" ]; then
    pass "~/.secrets/ (mode 700)"
  else
    fail "~/.secrets/ (mode $mode, forventet 700)"
  fi
else
  fail "~/.secrets/ (mangler)"
fi

if [ -f ~/.secrets/digipost-github-secret ]; then
  pass "~/.secrets/digipost-github-secret"
else
  fail "~/.secrets/digipost-github-secret (mangler)"
fi

# --------------------------------------------------------------------------
# Oppsummering
# --------------------------------------------------------------------------

echo ""
if [ "$ISSUES" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}Alt OK — ingen problemer funnet.${RESET}"
else
  echo -e "${RED}${BOLD}$ISSUES problem(er) funnet.${RESET}"
fi
echo ""

exit "$( [ "$ISSUES" -eq 0 ] && echo 0 || echo 1 )"
