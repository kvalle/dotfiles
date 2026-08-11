# Rectangle

`RectangleConfig.json` is not symlinked. `scripts/rectangle/setup.sh` copies the
file to Rectangle's import path:

```text
~/Library/Application Support/Rectangle/RectangleConfig.json
```

Rectangle reads the file at its next launch and then renames it with a
timestamp. After changing the configuration you therefore have to run the setup
script again, and restart Rectangle to import the changes:

```sh
~/dotfiles/scripts/rectangle/setup.sh
```
