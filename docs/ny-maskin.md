# Sjekkliste for ny maskin

## Automatisk oppsett

```sh
git clone https://github.com/kjetil/dotfiles.git ~/dotfiles
~/dotfiles/scripts/setup.sh
```

## Manuelt oppsett

- Sett opp en ny SSH-nøkkel og legg den til på GitHub:
  <https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account>
- Aktiver Touch ID og registrer fingeravtrykk.
- IntelliJ: gjør kommandolinjestarteren tilgjengelig via
  `Tools > Create Command Line Launcher`.
- Rectangle: åpne appen etter setup og gi nødvendige rettigheter. Oppsett og
  oppstart ved innlogging importeres automatisk.
- Fjern hurtigtastene for Spotlight (`cmd+space`) og
  `App shortcuts > Show help menu` (`shift+cmd+/`).
- Android Studio: hent `firstplayer_app.jks` fra Digipost til
  `~/dev/privat/keys`.
- Generelt: aktiver `tap to click`, `ctrl to zoom` under Accessibility og vis
  Bluetooth i menylinjen.
