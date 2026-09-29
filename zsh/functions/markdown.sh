# Render Markdown to self-contained HTML that follows the browser's light/dark
# mode. Shared metadata lives in quarto/markdown.yml; quarto comes from nix/flake.nix.
_md_quarto() {
  local quarto_dir="$DOTFILES/quarto"
  local tmpdir rc
  # BSD mktemp only randomizes trailing X's, so keep the .yml name inside a temp dir.
  tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/md-quarto.XXXXXX") || return 1
  sed "s|@QUARTO_DIR@|$quarto_dir|g" "$quarto_dir/markdown.yml" > "$tmpdir/markdown.yml" || {
    rm -rf "$tmpdir"
    return 1
  }
  env -u QUARTO_PANDOC quarto "$@" --to html --metadata-file "$tmpdir/markdown.yml"
  rc=$?
  rm -rf "$tmpdir"
  return $rc
}

md-preview() {
  _md_quarto preview "$@"
}

md-render() {
  _md_quarto render "$@"
}
