#!/bin/bash

# Casks som krever eleverte rettigheter (Privileges må være aktivert)

casks=(
  "kitty"     # Terminalemulator (for kitten CLI-verktøy)
  "soapui"    # SOAP/REST API-testing
  "idrive"    # Skybasert backup
)

echo "Følgende casks krever eleverte rettigheter:"
printf '  %s\n' "${casks[@]}"
echo ""
echo "Aktiver Privileges og trykk Enter for å fortsette..."
read -r

failed=()
for cask in "${casks[@]}"; do
  echo "Installerer $cask..."
  if ! brew install --cask "$cask"; then
    echo "Feilet: $cask"
    failed+=("$cask")
  fi
done

echo ""
echo "Nedgrader Privileges og trykk Enter for å fortsette..."
read -r

if [ ${#failed[@]} -gt 0 ]; then
  echo "Følgende casks feilet installering:"
  printf '  %s\n' "${failed[@]}"
  echo "Installer disse manuelt senere."
fi

echo "Ferdig med privilegerte casks."
