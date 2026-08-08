# Plan for opprydding av scripts

## Bakgrunn

Repoet har 18 scripts under `scripts/`, i tillegg til brukerkommandoer i
`bin/`, Zsh-funksjoner og enkelte app-spesifikke scripts.

Hovedproblemet er at `scripts/setup.sh` allerede fungerer som en liten
orkestrator over separate implementasjonsscripts, mens `scripts/update.sh` og
`scripts/verify.sh` inneholder mye av domenelogikken selv. `scripts/` blander
dermed offentlige entrypoints, installasjon, oppdatering, generering og
verifikasjon.

Målet er å beholde stabile entrypoints på toppen og organisere implementasjonen
etter det som administreres.

## Dagens struktur

| Område | Scripts og logikk |
| --- | --- |
| Orkestrering | `setup.sh`, `update.sh`, `verify.sh` |
| Homebrew | `setup/homebrew.sh`, Homebrew-delen av `update.sh` |
| Nix | `setup/nix.sh`, `nix-apply.sh`, `nix-profile-audit.sh`, Nix-delen av `update.sh` |
| Symlinker | `setup/symlinks.sh`, deler av `verify.sh` |
| macOS | `setup/macos.sh`, `setup/rectangle.sh` |
| Verktøy | `setup/nvm.sh`, `setup/fzf.sh`, `setup/bat.sh` |
| Secrets | `setup/secrets.sh`, deler av `verify.sh` |
| AI-skills | `setup/skills.sh`, `skills-manifest.sh`, deler av `update.sh` og `verify.sh` |
| Temaer | `generate-starship-configs.rb`, `verify-terminal-themes.sh`, deler av `verify.sh` |

Scripts under `bin/`, `zsh/`, `tuna/` og `ai/claude/` har egne runtime-formål
og bør ikke flyttes inn i denne strukturen. Git-submodulet `fzf-git.sh/` er
eksternt innhold og skal heller ikke reorganiseres.

## Foreslått struktur

```text
scripts/
├── setup.sh
├── update.sh
├── verify.sh
│
├── lib/
│   ├── common.sh
│   └── privileges.sh
│
├── brew/
│   ├── setup.sh
│   ├── update.sh
│   └── verify.sh
│
├── nix/
│   ├── setup.sh
│   ├── update.sh
│   ├── apply.sh
│   ├── verify.sh
│   └── audit-profiles.sh
│
├── symlinks/
│   ├── setup.sh
│   └── verify.sh
│
├── macos/
│   └── setup.sh
│
├── rectangle/
│   └── setup.sh
│
├── nvm/
│   └── setup.sh
│
├── bat/
│   ├── setup.sh
│   └── verify.sh
│
├── secrets/
│   ├── setup.sh
│   └── verify.sh
│
├── skills/
│   ├── setup.sh
│   ├── update.sh
│   ├── verify.sh
│   └── manifest.sh
│
└── themes/
    ├── generate-starship.rb
    └── verify.sh
```

Ikke alle domener trenger alle livssyklusoperasjonene. En katalog skal bare
inneholde operasjoner som faktisk finnes. Små enkeltkommandoer som
`tldr --update`, `jenv rehash` og oppdatering av submoduler kan fortsatt ligge
direkte i toppnivåscriptet.

## Flytting

| Nå | Forslag |
| --- | --- |
| `setup/homebrew.sh` | `brew/setup.sh` |
| Homebrew-logikk i `update.sh` | `brew/update.sh` |
| `setup/nix.sh` | `nix/setup.sh` |
| Nix-logikk i `update.sh` | `nix/update.sh` |
| `nix-apply.sh` | `nix/apply.sh` |
| `nix-profile-audit.sh` | `nix/audit-profiles.sh` |
| `setup/symlinks.sh` | `symlinks/setup.sh` |
| Symlink-kontroller i `verify.sh` | `symlinks/verify.sh` |
| `setup/macos.sh` | `macos/setup.sh` |
| `setup/rectangle.sh` | `rectangle/setup.sh` |
| `setup/nvm.sh` | `nvm/setup.sh` |
| `setup/bat.sh` | `bat/setup.sh` |
| `setup/secrets.sh` | `secrets/setup.sh` |
| `setup/skills.sh` | `skills/setup.sh` |
| Skill-logikk i `update.sh` | `skills/update.sh` |
| `skills-manifest.sh` | `skills/manifest.sh` |
| `generate-starship-configs.rb` | `themes/generate-starship.rb` |
| `verify-terminal-themes.sh` | `themes/verify.sh` |

`setup/fzf.sh` gjør i praksis bare en tilgjengelighetssjekk og kan trolig
fjernes. FZF kan i stedet verifiseres gjennom Brew- eller generell
verktøyverifikasjon.

## Entry points

Toppnivåscript skal beskrive arbeidsflyten, ikke implementere domenene.

`scripts/setup.sh` skal kalle relevante `setup.sh`-scripts og avslutte med
verifikasjon. `scripts/update.sh` skal sekvensiere domeneoppdateringer og små
enkeltkommandoer. `scripts/verify.sh` skal kjøre alle domenekontroller som
standard, og kan senere støtte valg av én kontroll via argument.

Eksempel på ønsket verifikasjonsgrensesnitt:

```text
scripts/verify.sh
scripts/verify.sh themes
scripts/verify.sh symlinks
scripts/verify.sh packages
```

## Felles konvensjoner

Før eller under flyttingen bør scripts samles om:

- én script-relativ mekanisme for å finne reporoten, med `DOTFILES` som
  eventuell override
- Bash for komplekse vedlikeholdsscripts
- en bevisst og konsistent feilpolicy
- felles funksjoner for logging og feilrapportering
- felles håndtering og `trap`-basert opprydding av midlertidige adminrettigheter
- et eksplisitt skille mellom obligatoriske og valgfrie setup-steg

## Funn som bør håndteres

- `update.sh` bruker `warn` før funksjonen er definert.
- Homebrew-oppsettet mangler robust `trap` for å fjerne midlertidige
  adminrettigheter.
- `setup/secrets.sh` erklærer `/bin/sh`, men bruker Bash-syntaks.
- Secrets-filen får ikke eksplisitt modus `600`.
- Symlinkscriptet bruker destruktiv `rm -rf` og `eval`.
- Scripts finner reporoten på flere forskjellige måter.
- Strict mode og shebang varierer betydelig.
- `verify.sh` blander rene repokontroller med kontroller som krever en ferdig
  konfigurert maskin.
- Setup-stegene har ulik idempotens og kritikalitet uten at orkestratoren gjør
  dette tydelig.
- Genererte filer, dokumentasjon og kall inneholder eksisterende scriptpaths
  som må oppdateres ved flytting.

### Oppfølging: skills fjernet upstream

`npx skills update -g -y` kan rapportere at installerte skills er slettet fra
kilden, uten å fjerne de lokale kopiene. Oppdateringsflyten bør oppdage dette
og spørre eksplisitt om de foreldreløse skillsene skal slettes lokalt. Sletting
skal ikke skje automatisk, siden lokale skills kan være i bruk eller ha
endringer som må vurderes først.

Dette ble observert for `batch-grill-me` og `writing-great-skills` fra
`mattpocock/skills` under manuell testing av `scripts/update.sh`.

## Gjennomføringsstrategi

Oppryddingen bør gjøres i domenevise etapper, med verifikasjon og helst en egen
commit mellom hver etappe. Ett stort løft er mulig, men gjør det vanskeligere å
skille path-feil fra atferdsendringer og å finne årsaken når maskinavhengige
scripts feiler.

### Etappe 1: Felles grunnlag

- etabler reporot- og loggingkonvensjoner i `lib/`
- rett `warn`-rekkefølgen i `update.sh`
- bestem feilpolicy og shebang-konvensjon
- gjør ingen domeneflytting samtidig hvis dette innebærer atferdsendringer

Verifiser Bash-syntaks og at eksisterende, ikke-destruktive kontroller fortsatt
kan kjøres.

### Etappe 2: Nix

Status: gjennomført.

- flytt `setup/nix.sh`, `nix-apply.sh` og `nix-profile-audit.sh`
- trekk Nix-oppdateringen ut av `update.sh`
- oppdater dokumentasjon og alle kall

Verifiser syntaks, gamle path-referanser og ikke-destruktiv Nix-audit. Selve
profiloppdateringen testes manuelt utenfor sandkassen.

### Etappe 3: Skills og temaer

- samle installasjon, oppdatering, manifest og verifikasjon av skills
- samle Starship-generator og terminaltemaverifikasjon
- oppdater genererte headere og dokumentasjon

Verifiser med manifestets `--check`, Starship-generatorens `--check` og
terminaltemaverifikasjonen.

### Etappe 4: Setup-domener

- flytt Homebrew, symlinker, macOS, Rectangle, NVM, Bat og secrets
- fjern eller absorber `setup/fzf.sh`
- behold `scripts/setup.sh` som stabilt entrypoint

Verifiser syntaks og paths automatisk. Homebrew, symlinker, macOS-defaults,
Rectangle og secrets testes manuelt utenfor sandkassen fordi de endrer
maskintilstand.

### Etappe 5: Update og verify

- gjør `update.sh` til en liten orkestrator
- del `verify.sh` etter domene
- skill rene repokontroller fra maskinavhengige kontroller
- legg eventuelt til valg av verifikasjonsdomene via argument

Kjør alle ikke-destruktive verifikasjoner og kontroller at standardkallet
fortsatt dekker hele systemet.

### Etappe 6: Herding og dokumentasjon

- herd symlinkhåndteringen før eller separat fra annen atferdsendring
- sikre secrets med streng filmodus og oppdatert 1Password-innlogging
- gjør privilege-cleanup robust
- oppdater `README.md`, `AGENTS.md`, `Brewfile` og relevante filer under `docs/`
- søk etter alle gamle paths

## Verifikasjon mellom etappene

Følgende kan kjøres automatisk og uten å endre maskintilstand:

- syntakssjekk av Bash- og gjenværende POSIX-sh-scripts
- Starship-generator med `--check`
- skill-manifest med `--check`
- terminaltemaverifikasjon
- søk etter gamle scriptpaths
- `git diff --check`

Full bootstrap, Homebrew-oppdatering, Nix-profilendringer, oppretting av
symlinker, macOS-defaults og secrets må verifiseres manuelt utenfor sandkassen.

## Anbefaling

Ikke gjør alt i én stor endring, men unngå også å flytte ett enkelt script om
gangen. Den beste balansen er én sammenhengende domenegruppe per etappe. Da kan
hver etappe etterlate repoet i en fungerende tilstand, samtidig som endringene
er store nok til at gamle og nye strukturer ikke må leve side om side lenge.

Behold `scripts/setup.sh`, `scripts/update.sh` og `scripts/verify.sh` som stabile
offentlige grensesnitt gjennom hele migreringen. Midlertidige wrappers for gamle
interne paths er bare nødvendig dersom de brukes utenfra eller er dokumenterte
brukergrensesnitt.
