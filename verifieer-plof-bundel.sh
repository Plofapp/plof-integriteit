#!/usr/bin/env bash
#
# verifieer-plof-bundel.sh
# ------------------------
# Onafhankelijke integriteitscontrole van de Plof post-quantum crypto-bundel.
#
# Dit script haalt (1) de crypto-bundel die plof.app op dit moment aan browsers
# serveert, en (2) de onafhankelijk op GitHub gepubliceerde hash, en vergelijkt
# ze. Als ze GELIJK zijn, is de bundel die jij van plof.app krijgt exact de
# bundel die Plof heeft gepubliceerd. Als ze VERSCHILLEN, is er iets mis — dan
# is de bundel op de server gewijzigd (mogelijk door een aanval) en moet je
# Plof NIET vertrouwen tot dit is uitgezocht.
#
# Waarom dit werkt: de GitHub-hash en de plof.app-server zijn twee losse
# systemen. Een aanvaller die alleen de webserver overneemt, kan de bundel
# vervangen, maar niet de hash op GitHub. Deze controle valt dan af.
#
# Gebruik:   bash verifieer-plof-bundel.sh
# Vereist:   curl en sha256sum (of shasum op macOS)

set -euo pipefail

BUNDEL_URL="https://plof.app/?plof_openen_pqc_js=1"
GITHUB_HASH_URL="https://raw.githubusercontent.com/Plofapp/plof-integriteit/main/plof-pqc.integriteit.json"

echo "Plof bundel-integriteitscontrole"
echo "================================="
echo

# 1. Hash van de LIVE bundel bij plof.app
echo "1. Bundel ophalen van plof.app ..."
LIVE_HASH="$(curl -fsSL "$BUNDEL_URL" | sha256sum | cut -d' ' -f1)"
echo "   Live hash (plof.app):  $LIVE_HASH"

# 2. Onafhankelijk gepubliceerde hash van GitHub
echo "2. Gepubliceerde hash ophalen van GitHub ..."
GITHUB_JSON="$(curl -fsSL "$GITHUB_HASH_URL")"
# sha256 uit de JSON trekken zonder jq-afhankelijkheid
GITHUB_HASH="$(printf '%s' "$GITHUB_JSON" | grep -o '"sha256"[[:space:]]*:[[:space:]]*"[a-f0-9]*"' | grep -o '[a-f0-9]\{64\}')"
echo "   GitHub hash:           $GITHUB_HASH"
echo

# 3. Vergelijken
if [ -z "$GITHUB_HASH" ]; then
  echo "FOUT: kon de GitHub-hash niet lezen. Controleer de URL of je internetverbinding."
  exit 2
fi

if [ "$LIVE_HASH" = "$GITHUB_HASH" ]; then
  echo "RESULTAAT: OK"
  echo "De bundel die plof.app serveert is identiek aan de gepubliceerde versie."
  exit 0
else
  echo "RESULTAAT: WAARSCHUWING - HASHES VERSCHILLEN"
  echo "De bundel op plof.app komt NIET overeen met de gepubliceerde hash."
  echo "Vertrouw de versleuteling nu niet. Neem contact op met Plof en onderzoek dit."
  exit 1
fi
