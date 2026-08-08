# Rectangle

`RectangleConfig.json` symlinkes ikke. `scripts/rectangle/setup.sh` kopierer
filen til Rectangles importsti:

```text
~/Library/Application Support/Rectangle/RectangleConfig.json
```

Rectangle leser filen ved neste oppstart og gir den deretter et tidsstemplet
navn. Etter endringer i konfigurasjonen må setup-scriptet derfor kjøres på nytt,
og Rectangle må startes på nytt for å importere endringene:

```sh
~/dotfiles/scripts/rectangle/setup.sh
```
