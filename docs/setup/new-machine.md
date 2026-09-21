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
- Rectangle: open the app after setup and grant the required permissions. The
  configuration and launch-at-login are imported automatically.
- Spotlight is configured as `cmd+option+space` by the macOS setup script;
  `cmd+space` remains available for Tuna. Remove `App shortcuts > Show help
  menu` (`shift+cmd+/`) manually if present.
- Android Studio: fetch `firstplayer_app.jks` from Digipost into
  `~/code/privat/keys`.
- General: enable `tap to click` and `ctrl to zoom` under Accessibility, and
  show Bluetooth in the menu bar.
