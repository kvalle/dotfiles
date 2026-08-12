# New machine checklist

## Automated setup

```sh
git clone https://github.com/kvalle/dotfiles.git ~/dotfiles
~/dotfiles/scripts/setup.sh
```

## Manual setup

- Create a new SSH key and add it to GitHub:
  <https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account>
- Enable Touch ID and register fingerprints.
- IntelliJ: make the command line launcher available via
  `Tools > Create Command Line Launcher`.
- Rectangle: open the app after setup and grant the required permissions. The
  configuration and launch-at-login are imported automatically.
- Set Spotlight to `option+space` manually under
  `Keyboard > Keyboard Shortcuts > Spotlight`. Remove
  `App shortcuts > Show help menu` (`shift+cmd+/`) manually if present.
- Android Studio: fetch `firstplayer_app.jks` from Digipost into
  `~/dev/privat/keys`.
- General: enable `tap to click` and `ctrl to zoom` under Accessibility, and
  show Bluetooth in the menu bar.
