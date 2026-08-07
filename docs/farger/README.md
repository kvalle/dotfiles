# Fargetemaer

Oppsettet bruker to navngitte temaer:

- **Dark mode:** [Catppuccin Macchiato](catppuccin-macchiato-palette.html), et
  standardtema fra Catppuccin.
- **Light mode:** [Everforest Light Contrast](everforest-light-contrast-palette.html),
  en egendefinert variant av Everforest Light, basert på Light Hard-paletten og
  justert for høyere kontrast.

## Drift og vedlikehold

- macOS er sannhetskilden for light/dark. Terminalene følger macOS direkte, mens
  Zsh oppdaterer modusavhengige verktøyvalg ved neste prompt. TUI-er som allerede
  kjører, må normalt startes på nytt etter et bytte.
- Verktøy skal arve terminalens ANSI-palett når det gir nok semantikk. Egne
  temafiler og wrappers brukes bare når verktøyet trenger eksplisitte farger.
- Starships runtime-filer genereres fra `starship/starship.toml.erb` med
  `scripts/generate-starship-configs.rb`. LazyGit bruker en felles dark-base og
  et light-overlay.
- btop, Superfile og Tuxedo velger tema gjennom små wrappers med midlertidig
  konfigurasjon. Det er ikke nødvendig med generell Kitty-palettgjenoppretting.
- Bat registrerer custom-temaer etter filnavnet; den tekniske ID-en er
  `everforest-light-contrast`. Etter endringer i Bat-temaet, kjør
  `bat cache --build`. Kontroller hele oppsettet med
  `scripts/verify-terminal-themes.sh`.
