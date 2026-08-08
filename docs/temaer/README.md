# Terminaltemaer

Oppsettet bruker to navngitte temaer:

- **Dark mode:** [Catppuccin Macchiato](https://kvalle.github.io/dotfiles/temaer/paletter/catppuccin-macchiato.html),
  et standardtema fra Catppuccin.
- **Light mode:** [Everforest Light Contrast](https://kvalle.github.io/dotfiles/temaer/paletter/everforest-light-contrast.html),
  en lokal variant av Everforest Light Hard, justert for høyere kontrast.

macOS er sannhetskilden for light/dark. Kitty og Ghostty følger macOS direkte,
mens Zsh oppdaterer modusavhengige verktøyvalg ved neste prompt. TUI-er som
allerede kjører, må normalt startes på nytt etter et bytte.

## Prinsipper

- Verktøy arver terminalens ANSI-palett når det gir nok semantikk.
- Egne temafiler og wrappers brukes bare når verktøyet trenger eksplisitte
  farger eller ikke kan velge tema selv.
- `zsh/appearance.sh` er eneste sted som velger modusavhengig konfigurasjon.
- Light- og dark-oppsettene skal være semantisk konsistente på tvers av
  terminaler, prompt, diffverktøy og TUI-er.

## Drift og vedlikehold

- Starships runtime-filer genereres fra `starship/starship.toml.erb` med
  `scripts/themes/generate-starship.rb`. LazyGit bruker en felles dark-base og
  et light-overlay.
- btop, Superfile og Tuxedo velger tema gjennom små wrappers med midlertidig
  konfigurasjon. Det er ikke nødvendig med generell Kitty-palettgjenoppretting.
- Bat registrerer custom-temaer etter filnavnet; den tekniske ID-en er
  `everforest-light-contrast`. Etter endringer i Bat-temaet, kjør
  `bat cache --build`.

## Verifikasjon

Kjør den automatiske kontrollen etter endringer:

```sh
~/dotfiles/scripts/themes/verify.sh
```

Ved visuelle endringer bør relevante verktøy også kontrolleres manuelt i både
Kitty og Ghostty, i light og dark mode. Kontroller vanlig og dempet tekst,
valgte rader, rammer, diff, syntaksutheving, søketreff og statuslinjer.
