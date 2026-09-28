md-preview() {
  env -u QUARTO_PANDOC nix run 'github:NixOS/nixpkgs/25.11#quartoMinimal' -- \
    preview "$@" --to html \
    -M theme:litera \
    -M toc:true \
    -M toc-title:Innhold \
    -M lang:nb \
    -M embed-resources:true
}

md-render() {
  env -u QUARTO_PANDOC nix run 'github:NixOS/nixpkgs/25.11#quartoMinimal' -- \
    render "$@" --to html \
    -M theme:litera \
    -M toc:true \
    -M toc-title:Innhold \
    -M lang:nb \
    -M embed-resources:true
}
