# Terminal themes

The setup uses two named themes:

- **Dark mode:** [Catppuccin Macchiato](https://kvalle.github.io/dotfiles/themes/palettes/catppuccin-macchiato.html),
  a standard theme from Catppuccin.
- **Light mode:** [Everforest Light Contrast](https://kvalle.github.io/dotfiles/themes/palettes/everforest-light-contrast.html),
  a local variant of Everforest Light Hard, adjusted for higher contrast.

macOS is the source of truth for light/dark. Kitty and Ghostty follow macOS
directly, while Zsh updates mode-dependent tool choices at the next prompt. TUIs
that are already running normally have to be restarted after a switch.

## Principles

- Tools inherit the terminal's ANSI palette when that carries enough semantics.
- Dedicated theme files and wrappers are used only when a tool needs explicit
  colors or cannot pick a theme itself.
- `zsh/appearance.sh` is the only place that selects mode-dependent
  configuration.
- The light and dark setups should be semantically consistent across terminals,
  prompt, diff tools and TUIs.

## Operation and maintenance

- Starship's runtime files are generated from `starship/starship.toml.erb` with
  `scripts/themes/generate-starship.rb`. LazyGit uses a shared dark base and a
  light overlay.
- btop, Superfile and Tuxedo select their theme through small wrappers with
  temporary configuration. No general Kitty palette restoration is needed.
- Bat registers custom themes by file name; the technical ID is
  `everforest-light-contrast`. After changing the Bat theme, run
  `bat cache --build`.

## Verification

Run the automated check after making changes:

```sh
~/dotfiles/scripts/themes/verify.sh
```

For visual changes, the relevant tools should also be checked manually in both
Kitty and Ghostty, in light and dark mode. Check regular and dimmed text,
selected rows, borders, diffs, syntax highlighting, search matches and status
lines.
