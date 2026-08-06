# Automatisk light/dark-terminaltema

## Mål

Kitty og terminalprogrammene skal følge aktivt light/dark-utseende i macOS.
Oppsettet skal bruke:

- Light mode: lokalt avledet Everforest Light Hard Contrast.
- Dark mode: Catppuccin Macchiato.
- Starship i light mode: Everforest Light Hard Contrast.

Fargene skal være lesbare og semantisk konsistente i vanlige CLI-verktøy,
prompten og fullskjerms-TUI-er.

## Beslutninger

- macOS-utseendet er sannhetskilden for light/dark.
- Everforest Light Hard Contrast er det eneste light-oppsettet.
- Everforest Contrast beholder Everforest Light Hard-bakgrunnene, men bruker
  mørkere foreground, ANSI-farger og UI-aksenter.
- Alle egne light-temaer skal bruke den samme kontrastpaletten.
- OpenCode bruker custom-temaet `everforest-macchiato`, med Everforest Contrast
  i light og Catppuccin Macchiato i dark. OpenCode velger variant automatisk
  fra terminalens bakgrunn.
- Programmer som kan arve ANSI-paletten skal gjøre det. Egne temafiler brukes
  bare når programmet trenger flere semantiske farger eller eksplisitte
  bakgrunner.

## Begrensninger

- Kitty kan bytte egen palett mens programmet kjører.
- Kitty kan ikke endre miljøvariabler i et allerede kjørende shell.
- Zsh oppdaterer derfor modusavhengige variabler ved neste prompt.
- Allerede kjørende TUI-er må normalt startes på nytt etter et temabytte.
- TUI-er som bruker alternate screen kan i prinsippet nullstille dynamiske
  terminalfarger, men dette ble ikke reprodusert med det endelige LazyGit-
  oppsettet.

## Implementert

### Kitty

- `kitty/light-theme.auto.conf` inkluderer Everforest Light Hard Contrast.
- `kitty/dark-theme.auto.conf` bruker Catppuccin Macchiato.
- Kitty følger macOS automatisk ved bytte mellom light og dark.
- Ghostty bruker repo-eide temaer med samme foreground, background, selection,
  cursor og ANSI 0-15 som Kitty, og velger light/dark automatisk fra macOS.

### Zsh og Starship

- `zsh/appearance.sh` sjekker macOS-utseendet før hvert prompt.
- Appearance-laget eksporterer `TERMINAL_APPEARANCE` og velger sentralt
  Starship, LazyGit, Bat, Delta og fzf. Utenfor macOS og ved feil brukes light
  uten gjentatte feilmeldinger.
- Dark mode bruker `starship/starship.toml` med Catppuccin Macchiato.
- Light mode bruker `starship/starship-light.toml` med Everforest
  Contrast-paletten.

### LazyGit og Delta

- LazyGit slår sammen felles konfigurasjon med
  `lazygit/themes/everforest-contrast.yml` i light mode.
- Everforest Contrast har tydeligere tekst, rammer og markerte linjer.
- Delta bruker `--light` og lyse, palettilpassede diffbakgrunner i light mode.
- Syntaksutheving i Delta bruker foreløpig `Monokai Extended Light`, ikke et
  ekte Everforest-syntakstema.
- LazyGit ble testet uten wrapper; Kitty-paletten var identisk før og etter.
  Wrapperen og Kitty remote control ble derfor fjernet.

### fzf

- `FZF_DEFAULT_OPTS` beholder felles layoutflagg og får en komplett
  modusavhengig mapping for bakgrunn, tekst, treff, spinner, header, info,
  pointer, marker og prompt.
- Ctrl-T, Alt-C, OpenCode- og Digipost-velgerne arver grunnpaletten.
- `fzf-git.sh` beholdes urørt; ANSI-labels og underline-attributter kombineres
  med den sentrale paletten uten å erstatte den.

### Dokumentasjon

- Palettsider finnes for Catppuccin Macchiato og Everforest Light Hard
  Contrast.
- Sidene lenker til offisielle kilder, viser komplette semantiske paletter og
  støtter klikk for å kopiere hexkoder.
- Kontrastvarianten er dokumentert som en lokal avledning.
- Den semantiske kontrastmappingen er foreground `#3d4c4f`, muted `#68766d`,
  red `#b83f3d`, orange `#c65f18`, yellow `#a87700`, green `#657a00`, aqua
  `#287f60`, blue `#2c7198` og purple `#aa4d8e`. Hovedbakgrunnen er `#fffbef`,
  dempet bakgrunn `#f2efdf`, valgt bakgrunn `#e4e8bd`, slettet bakgrunn
  `#f8d4ca` og informasjonsbakgrunn `#d8e7df`.

## Nåværende avvik

- Bat bruker midlertidig `Monokai Extended Light` i light mode frem til det
  egne Everforest-syntakstemaet i Ticket 4 er på plass.
- `eza/theme.yml` består av faste Catppuccin Macchiato-farger.
- btop og Superfile bruker faste Catppuccin Macchiato-temaer.
- OpenCode bruker nå custom-temaet `everforest-macchiato`; både `system` og det
  innebygde Everforest-temaet ble forkastet etter visuell testing.
- `ai/claude/settings.json` bruker eksplisitt `dark`.
- Atuin, Glow, Tealdeer og Tuxedo er ikke visuelt verifisert i begge moduser.

## Gjennomføringsstrategi

- Ticket 1 etablerer grensesnittet resten bygger på og må tas først.
- Ticket 2 til 9 kan deretter gjennomføres uavhengig, med oppgitte
  avhengigheter.
- Ticket 10 samler robusthetsarbeid som først gir mening når wrappers og
  temavalg er på plass.
- Ticket 11 undersøker konfigurasjonsdeling når alle konkrete behov er kjent.
- Ticket 12 er ende-til-ende-godkjenning og tas sist.
- Hver ticket skal etterlate verktøyet fungerende i både light og dark; det skal
  ikke merges en Everforest-endring som samtidig ødelegger Macchiato.
- Bruk repoet som kilde for alle konfigurasjoner. Nye filer uten eksisterende
  symlink må legges til i `symlinks.conf`.
- Foretrekk terminalens ANSI-palett eller innebygd `system`/`auto` når det gir
  nok semantikk. Bruk separate konfigurasjoner eller wrappers bare når
  programmet ikke kan følge terminalen selv.
- Ikke lag en generell temagenerator uten at minst tre filformater kan dele
  faktisk logikk. Palettverdier kan dupliseres mellom verktøyspesifikke filer,
  men semantisk mapping skal dokumenteres og være konsekvent.

## Testmatrise

Test hvert relevant program i både Everforest Contrast light mode og
Catppuccin Macchiato dark mode:

- vanlig, dempet og deaktivert tekst
- valgte og inaktive linjer
- aktive og inaktive rammer
- feil, advarsler og suksessmarkeringer
- diff og syntaksutheving
- søketreff, menyer og statuslinjer
- programstart før og etter neste shell-prompt
- macOS-bytte mens Kitty er åpen
- avslutning av alternate-screen-programmer
- nye Kitty-vinduer og faner etter temabytte

## Ferdigkriterier

- Kitty følger macOS automatisk i alle åpne og nye vinduer.
- Starship, LazyGit, Delta, fzf, Bat og eza velger riktig modus uten manuell
  konfigurasjon.
- Fullskjerms-TUI-er er lesbare og velger riktig tema ved oppstart.
- Ingen programmer etterlater terminalen med feil bakgrunn eller ANSI-palett.
- Ingen testede visninger har utilstrekkelig kontrast i Everforest Contrast
  eller Catppuccin Macchiato.
- Temaoppsettet har én tydelig light/dark-kilde og minst mulig duplisert logikk.

# Tickets

## Ticket 1: Etabler felles appearance-kontrakt

**Status:** Implementert og manuelt verifisert.

**Mål:** Gi alle senere tickets én stabil måte å finne aktiv modus og tilhørende
konfigurasjon på.

**Avhenger av:** Ingen.

**Berørte filer:** `zsh/appearance.sh`, `zsh/environment.sh`, `zsh/tools.sh`,
eventuelt `bin/macos-appearance` og denne planen.

**Arbeid:**

- Definer `TERMINAL_APPEARANCE` med verdien `light` eller `dark`.
- Samle lesing av `AppleInterfaceStyle` ett sted, med light som fallback når
  nøkkelen ikke finnes.
- La Zsh-hooken oppdatere modusavhengige variabler ved oppstart og `precmd`, men
  bare gjøre nye eksporter når modusen har endret seg.
- Definer hvilke variabler som skal styres sentralt: minst `STARSHIP_CONFIG`,
  `LG_CONFIG_FILE`, `BAT_THEME`, Delta-valg og `FZF_DEFAULT_OPTS`.
- Fjern statiske modusavhengige verdier fra `zsh/environment.sh` og
  `zsh/tools.sh` etter hvert som de flyttes inn i appearance-laget.
- Dokumenter den semantiske Everforest-mappingen for foreground, muted, red,
  orange, yellow, green, aqua, blue, purple og relevante bakgrunner. Bruk
  `docs/farger/everforest-light-hard-contrast-palette.html` som palettreferanse.
- Avklar oppførsel utenfor macOS og ved feil fra `defaults`; fallback skal være
  deterministisk og ikke skrive feilmeldinger ved hvert prompt.

**Akseptansekriterier:**

- Et nytt shell har korrekt `TERMINAL_APPEARANCE` og Starship/LazyGit-oppsett.
- Et eksisterende shell oppdateres ved første prompt etter macOS-bytte.
- Gjentatte prompt uten modusbytte endrer ikke miljøet eller starter prosesser
  utover den nødvendige appearance-sjekken.
- `zsh -n` godkjenner alle endrede Zsh-filer.

## Ticket 2: Fullfør terminalemulatorene

**Status:** Implementert og manuelt verifisert i Kitty og Ghostty.

**Mål:** Sørge for at både Kitty og Ghostty gir riktig grunnpalett før øvrige
programmer startes.

**Avhenger av:** Ticket 1 for felles begreper og fallback.

**Berørte filer:** `kitty/kitty.conf`, `kitty/light-theme.auto.conf`,
`kitty/dark-theme.auto.conf`, `kitty/themes/everforest-light-hard-contrast.conf`,
`ghostty/config` og eventuelle nye Ghostty-temafiler.

**Arbeid:**

- Verifiser alle Kitty-felter mot palettkontrakten: foreground, background,
  selection, cursor, URL, borders, tabs og ANSI 0-15.
- Test Kittys automatiske macOS-bytte i eksisterende vinduer, nye vinduer og
  nye faner.
- Undersøk Ghosttys dokumenterte støtte for separate light/dark-temaer og
  macOS-appearance.
- Lag en Ghostty-kompatibel Everforest Contrast-palett dersom det ikke finnes
  et innebygd tema med de lokale kontrastverdiene.
- Konfigurer Ghostty med Everforest Contrast i light og Catppuccin Macchiato i
  dark, eller dokumenter en minimal wrapper/reload-løsning dersom automatisk
  valg ikke støttes.

**Akseptansekriterier:**

- Kitty og Ghostty starter med riktig palett i begge macOS-moduser.
- Kitty oppdaterer åpne vinduer uten omstart.
- ANSI 0-15 og standard foreground/background er visuelt konsistente mellom
  Kitty og Ghostty.
- Ingen terminal peker til Catppuccin Latte eller et utgått light-tema.

## Ticket 3: Gjør fzf appearance-bevisst

**Status:** Implementert, avventer manuell visuell verifikasjon.

**Mål:** Gi alle fzf-flater Everforest Contrast i light og Macchiato i dark.

**Avhenger av:** Ticket 1.

**Berørte filer:** `zsh/tools.sh`, `zsh/appearance.sh`, `fzf-git.sh/fzf-git.sh`
bare dersom upstream-integrasjonen krever en lokal endring.

**Arbeid:**

- Flytt `FZF_DEFAULT_OPTS` sin fargedel ut av statisk tool-init.
- Behold felles layout-, border- og height-flagg uavhengig av modus.
- Map fzf-rollene `bg`, `bg+`, `fg`, `fg+`, `hl`, `hl+`, `spinner`, `header`,
  `info`, `pointer`, `marker` og `prompt` til begge palettene.
- Sørg for at eksisterende funksjoner som legger til egne fzf-flagg arver
  grunnpaletten uten å overskrive den utilsiktet.
- Test vanlig `fzf`, Ctrl-T, Alt-C, OpenCode-worktree-velgeren,
  Digipost-velgeren og alle bindings fra `fzf-git.sh`.
- Test preview med Bat og eza på nytt etter Ticket 4 og 5.

**Akseptansekriterier:**

- Alle nevnte fzf-innganger bruker korrekt palett i begge moduser.
- Valgt rad, søketreff og pointer har tydelig kontrast.
- `FZF_DEFAULT_OPTS` skifter ved neste prompt uten nytt shell.
- Ikke-fargerelaterte fzf-flagg er uendret.

## Ticket 4: Samordne Bat, Delta og LazyGit-diff

**Mål:** Bruke samme syntakspalett og diffsemantikk i Bat, Git/Delta og
LazyGit.

**Avhenger av:** Ticket 1.

**Berørte filer:** ny Bat-konfigurasjon og syntakstema under en repo-eid
`bat/`-katalog, `symlinks.conf`, `git/config`, `lazygit/config.yml`,
`lazygit/themes/everforest-contrast.yml`, `zsh/appearance.sh` og
`zsh/environment.sh`.

**Arbeid:**

- Finn et vedlikeholdbart Sublime Text/`.tmTheme`-grunnlag for Everforest Light
  og tilpass foreground/aksenter til den lokale kontrastpaletten.
- Legg Bat-konfigurasjon og custom theme i repoet og registrer nødvendig symlink.
- Dokumenter at brukeren må bygge Bat-cache etter nye syntakstemaer dersom Bat
  krever dette.
- Velg `BAT_THEME` automatisk mellom Everforest Contrast og Catppuccin
  Macchiato.
- Del Delta-oppsettet i navngitte light/dark-features eller en tilsvarende
  mekanisme som kan velges fra miljøet uten å omskrive `git/config`.
- Bruk Everforest-syntakstemaet og kontrastpalettens grønne/røde bakgrunner for
  light diff.
- Behold Catppuccin Macchiato og eksisterende dark diffbakgrunner i dark mode.
- La LazyGit bruke de samme Delta-feature-settene i stedet for å duplisere hele
  Delta-kommandoen.
- Fjern `Monokai Extended Light` når Everforest-temaet er på plass.

**Akseptansekriterier:**

- `bat`, `git diff`, `git show`, interaktiv Git-diff og LazyGit-diff bruker
  riktig syntaks og diffbakgrunner i begge moduser.
- Tillegg, slettinger, emphasis, line numbers og syntax er lesbare.
- `git config --list` og LazyGit-konfigurasjonen kan lastes uten feil.
- Bat-cache kan bygges fra dokumentert kommando på en ny maskin.

## Ticket 5: Gjør eza og shellfargene portable

**Mål:** Fjerne faste Macchiato-hexverdier fra filvisning og sikre lesbare
shellfarger i begge moduser.

**Avhenger av:** Ticket 1 og Ticket 2.

**Berørte filer:** `eza/theme.yml`, eventuelle nye `eza`-temakataloger,
`zsh/appearance.sh`, `zsh/colors.sh`, `zsh/completions.sh` og
`zsh/aliases.sh` ved behov.

**Arbeid:**

- Prøv først å mappe eza-rollene til ANSI-farger slik at Kitty/Ghostty er
  sannhetskilden.
- Verifiser at eza-formatet støtter valgt ANSI-representasjon for alle rollene
  som nå har hexverdier.
- Bruk separate light/dark-config paths bare dersom ANSI gir utilstrekkelig
  semantikk eller kontrast.
- Dekk file kinds, permissions, sizes, users, links, Git-status, security
  context, file types, punctuation, dates, headers og broken symlinks.
- Test Zsh-hjelpetekst som bruker `zsh/colors.sh`, completion-lister som bruker
  `LS_COLORS`, og alle `eza`-aliaser.
- Kontroller eza-previewene i fzf etter Ticket 3.

**Akseptansekriterier:**

- Ingen faste Macchiato-hexverdier gjenstår i aktiv eza light-konfigurasjon.
- Vanlige filer, mapper, executable, symlinks, Git-status og permissions er
  tydelig forskjellige i begge moduser.
- Zsh-hjelpetekst og completion er lesbare uten modusspesifikke funksjonskopier.
- `eza` kan laste konfigurasjonen uten warning eller fallback.

## Ticket 6: Lag automatisk tema for btop

**Mål:** Starte btop med riktig fullverdig tema uten å endre brukerens øvrige
btop-innstillinger.

**Avhenger av:** Ticket 1.

**Berørte filer:** `btop/btop.conf`, `btop/themes/catppuccin_macchiato.theme`,
nytt Everforest-tema og en eventuell `zsh/functions/btop.sh`.

**Arbeid:**

- Lag et komplett btop-tema fra Everforest Contrast-paletten, inkludert alle
  tekstroller, bokser, meters og gradienter.
- Behold Macchiato-temaet for dark mode.
- Velg mellom én wrapper med modusspesifikk `--config` og separate configs;
  unngå å generere eller endre en tracked config ved hver oppstart.
- Sørg for at endringer gjort inne i btop ikke utilsiktet skriver over
  temavalget eller lager støy i repoet.
- Test prosessliste, valgt rad, CPU/memory/network-grafer, temperaturer,
  disabled tekst og popup-dialoger.
- Test avslutning etter macOS-bytte for å se om terminalpaletten påvirkes.

**Akseptansekriterier:**

- `btop` velger Everforest Contrast i light og Macchiato i dark ved oppstart.
- Alle felter i btop-temaformatet er eksplisitt dekket.
- Vanlige btop-innstillinger beholdes i én autoritativ config.
- Ingen absolute home-paths er nødvendige i tracked konfigurasjon dersom btop
  støtter relative temanavn.

## Ticket 7: Lag automatisk tema for Superfile

**Mål:** Gi Superfile et lokalt Everforest Contrast-tema og automatisk
light/dark-valg.

**Avhenger av:** Ticket 1 og Ticket 4 dersom Bat brukes som previewer.

**Berørte filer:** `superfile/config.toml`, `superfile/hotkeys.toml`, nye
Superfile-temafiler, `symlinks.conf` og en eventuell wrapper.

**Arbeid:**

- Verifiser mot gjeldende Superfile-dokumentasjon hvor custom themes ligger,
  hvilket schema de bruker, og om config/theme kan velges med CLI eller miljø.
- Legg tema og eventuelle ekstra symlinks i repoet; ikke skriv direkte under
  `~/Library/Application Support`.
- Lag en komplett Everforest Contrast-mapping for panels, borders, selection,
  search, status, errors, file types og preview.
- Behold Catppuccin Macchiato i dark mode.
- Velg innebygd config/theme-mekanisme fremfor wrapper dersom mulig.
- Vurder `code_previewer = "bat"` etter at Ticket 4 er ferdig; behold builtin
  preview hvis Bat-integrasjonen gir dårligere eller inkonsistent resultat.
- Superfile er ikke tilgjengelig i nåværende sandbox-PATH; dokumenter konkrete
  manuelle teststeg på vertsmaskinen.

**Akseptansekriterier:**

- Superfile starter med riktig tema i begge moduser.
- Tema- og configfiler eies av repoet og er representert i `symlinks.conf`.
- Filpanel, sidebar, preview, dialoger og valgte/inaktive rader er lesbare.
- Temavalg endrer ikke hotkeys eller øvrig funksjonalitet.

## Ticket 8: Korriger OpenCode og Claude Code

**Mål:** Få begge AI-TUI-ene til å følge aktivt utseende uten å påvirke
sandbox-, tillatelses- eller agentinnstillinger.

**Avhenger av:** Ticket 1 og Ticket 2.

**Berørte filer:** `ai/opencode/tui.jsonc`, `ai/opencode/themes/`,
`ai/claude/settings.json`,
`zsh/functions/opencode.sh` og eventuelle Claude/OpenCode-wrappers eller
modusspesifikke settings-filer.

**Arbeid:**

- Verifiser custom-temaet `everforest-macchiato` i begge moduser. `system` ble
  forkastet fordi flater og aksenter ble for grå i light mode; innebygd
  Everforest ble forkastet fordi dark-bakgrunnen ikke matchet Macchiato.
- Undersøk hvilke gyldige Claude Code-temaverdier som finnes og om `system`,
  automatisk terminaldeteksjon eller per-oppstart `--settings` støttes.
- Hvis Claude Code bare støtter eksplisitt `light`/`dark`, lag to minimale
  overlay-settings og velg dem ved oppstart uten å duplisere hovedinnstillingene.
- Ikke endre permissions, default mode, statusline, notifications eller cplt-
  oppførsel som del av temaarbeidet.
- Test markdown, kodeblokker, diff, tool-status, spørsmål, selected rows,
  warnings og statusline i begge TUI-er.

**Akseptansekriterier:**

- OpenCode og Claude Code velger et lesbart tema som samsvarer med aktiv modus.
- OpenCode bruker `everforest-macchiato` og matcher terminalens hovedbakgrunn i
  begge moduser.
- Claude Code bruker ikke lenger fast `dark` i light mode.
- Eksisterende sikkerhets- og arbeidsflytinnstillinger er bit-for-bit uendret
  bortsett fra nødvendig temakonfigurasjon.

## Ticket 9: Verifiser ANSI-arvende verktøy og Glow

**Mål:** Dekke verktøyene som sannsynligvis kan følge terminalpaletten uten
egne komplette temapar.

**Avhenger av:** Ticket 1, Ticket 2 og Ticket 5.

**Berørte filer:** `atuin/config.toml`, `tealdeer/config.toml`,
`tuxedo/config.toml`, `glow/glow.yml`, `zsh/appearance.sh` og eventuelle nye
Atuin-temafiler.

**Arbeid:**

- Test Atuins standardtema i begge moduser. Hvis rollene ikke er tydelige, lag
  et ANSI-basert custom theme som fortsatt arver terminalpaletten.
- Verifiser AlertInfo, AlertWarn, AlertError, Annotation, Base, Guidance og
  Important dersom et Atuin-tema opprettes.
- Test Tealdeers eksisterende named ANSI colors og `ansi = 15`, særlig vanlig
  eksempeltekst mot Everforest-bakgrunnen.
- Behold Tuxedo `Terminal` dersom alle states er lesbare; ikke erstatt et
  fungerende terminalarvet tema med dupliserte hexverdier.
- Undersøk Glows støtte for `auto`, `light`, `dark`, `notty` og
  `GLAMOUR_STYLE`; velg automatikk eller modusavhengig miljøvariabel.
- Test Glow både direkte og gjennom pager, med headings, code blocks, links,
  blockquotes og lister.

**Akseptansekriterier:**

- Atuin, Tealdeer, Tuxedo og Glow er visuelt godkjent i begge moduser.
- Verktøy som fungerer med ANSI beholder én statisk konfigurasjon.
- Eventuelle modusspesifikke valg styres av appearance-kontrakten, ikke egne
  macOS-sjekker.
- Ingen ny wrapper innføres uten dokumentert behov.

## Ticket 10: Herd alternate-screen og live-bytte

**Mål:** Unngå at TUI-er etterlater terminalen med feil palett og redusere
Kitty-spesiallogikken til minste nødvendige omfang.

**Avhenger av:** Ticket 2, Ticket 4, Ticket 6, Ticket 7, Ticket 8 og Ticket 9.

**Berørte filer:** Eventuelle wrappers, `kitty/kitty.conf` og
`zsh/appearance.sh`.

**Arbeid:**

- Reproduser og dokumenter nøyaktig hvilke TUI-er som nullstiller Kittys
  dynamiske farger ved alternate-screen exit.
- Test LazyGit, btop, Superfile, OpenCode, Claude Code, Atuin, Tuxedo og Glow.
- Generaliser gjenpåføring i én liten helper bare dersom minst to programmer
  trenger identisk behandling.
- Sørg for at wrappers bevarer argumenter, exit status, signaler og vanlig
  command resolution.
- Test avslutning både før og etter macOS-bytte mens TUI-en kjører.

**Akseptansekriterier:**

- Ingen testet TUI etterlater feil foreground, background eller ANSI-palett.
- Wrappers returnerer underliggende programs exit status.
- Kitty remote control er fjernet dersom ingen annen TUI trenger det.
- Ghostty påvirkes ikke negativt av Kitty-spesifikk logikk.

## Ticket 11: Reduser konfigurasjonsduplisering

**Mål:** Ha én autoritativ kilde for felles Starship- og LazyGit-oppsett uten å
gjøre runtime-løsningen mer skjør eller kompleks enn nødvendig.

**Avhenger av:** Ticket 1, Ticket 3 og Ticket 4.

**Berørte filer:** `starship/starship.toml`,
`starship/starship-light.toml`, `lazygit/config.yml`,
`lazygit/themes/everforest-contrast.yml`, `zsh/appearance.sh` og eventuelle små
generatorfiler eller valideringsskript.

**Arbeid:**

- Sammenlign Starship-filene og klassifiser forskjellene som felles struktur,
  dark-palett, light-palett eller reelt modusavhengig moduloppsett.
- Ta hensyn til at Starship 1.26 ikke støtter include, arv, lagdelte configs,
  miljøinterpolering eller runtime-valg av palett.
- Vurder tre løsninger for Starship: behold to håndskrevne filer, generer to
  komplette filer fra én mal, eller bruk én ANSI-basert config.
- Velg generering bare dersom den reduserer reell vedlikeholdsrisiko uten å
  innføre skjulte eller maskinavhengige build-steg.
- Undersøk om LazyGits eksisterende base + light-overlay allerede er minste
  praktiske duplisering, eller om theme-verdier og Delta-oppsett kan samles
  bedre etter Ticket 4.
- Appearance-laget skal forbli eneste sted som velger `LG_CONFIG_FILE`.
- Dokumenter hvorfor eventuell gjenværende duplisering er nødvendig dersom
  verktøyformatene ikke støtter trygg komposisjon.

**Akseptansekriterier:**

- Felles Starship-struktur vedlikeholdes enten ett sted eller har en eksplisitt
  begrunnelse for fortsatt duplisering.
- LazyGit har én baseconfig og bare de modusspesifikke override-verdiene som
  faktisk er nødvendige.
- Ingen genererte filer kan bli stille utdaterte uten at validering oppdager det.
- Appearance-hooken er eneste eier av `STARSHIP_CONFIG` og `LG_CONFIG_FILE`.

## Ticket 12: Ende-til-ende-verifikasjon og opprydding

**Mål:** Godkjenne hele løsningen som én sammenhengende light/dark-opplevelse.

**Avhenger av:** Ticket 1 til 11.

**Berørte filer:** Alle temafiler, denne planen og eventuell brukerdokumentasjon.

**Arbeid:**

- Kjør hele testmatrisen i både Kitty og Ghostty, i light og dark.
- Test nytt login-shell, eksisterende shell før/etter prompt, nye faner og nye
  vinduer.
- Test alle verktøy eksplisitt: Starship, fzf, Bat, Delta, eza, LazyGit, btop,
  Superfile, OpenCode, Claude Code, Atuin, Tealdeer, Tuxedo og Glow.
- Søk etter foreldede referanser til Catppuccin Latte, Flexoki, Rose Pine,
  Tokyo Night som aktivt TUI-tema, Monokai Extended Light og gamle genererte
  light-theme-filer.
- Søk etter aktive Macchiato-hexverdier i light-spesifikke filer og avklar hvert
  treff.
- Valider Zsh-syntaks, TOML, YAML, JSON/JSONC og verktøyenes egne config-checks
  der de finnes.
- Kjør `git diff --check` og inspiser hele diffen for utilsiktede endringer.
- Oppdater seksjonen `Implementert`, fjern `Nåværende avvik`, og marker hver
  ticket med ferdigstatus når akseptansekriteriene er oppfylt.
- Dokumenter eventuell nødvendig vertsmaskinhandling, som Bat-cache-bygging
  eller kjøring av symlink-scriptet; ikke utfør slike endringer fra sandboxen.

**Akseptansekriterier:**

- Alle overordnede ferdigkriterier og hele testmatrisen er oppfylt.
- Ingen foreldede light-temaer eller velgere finnes i repoet.
- Alle configfiler kan parses eller lastes av tilhørende verktøy.
- Planen beskriver faktisk sluttstatus og eventuelle kjente restrisikoer.
