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

controleer() {
  local NAAM="$1" BUNDEL_URL="$2" GITHUB_HASH_URL="$3"
  echo "== $NAAM"
  echo "1. Bundel ophalen van plof.app ..."
  local LIVE_HASH GITHUB_JSON GITHUB_HASH
  LIVE_HASH="$(curl -fsSL "$BUNDEL_URL" | sha256sum | cut -d' ' -f1)"
  echo "   Live hash (plof.app):  $LIVE_HASH"
  echo "2. Gepubliceerde hash ophalen van GitHub ..."
  GITHUB_JSON="$(curl -fsSL "$GITHUB_HASH_URL")"
  # sha256 uit de JSON trekken zonder jq-afhankelijkheid
  GITHUB_HASH="$(printf '%s' "$GITHUB_JSON" | grep -o '"sha256"[[:space:]]*:[[:space:]]*"[a-f0-9]*"' | grep -o '[a-f0-9]\{64\}')"
  echo "   GitHub hash:           $GITHUB_HASH"
  if [ -z "$GITHUB_HASH" ]; then
    echo "   FOUT: kon de GitHub-hash niet lezen. Controleer de URL of je internetverbinding."
    return 2
  fi
  if [ "$LIVE_HASH" = "$GITHUB_HASH" ]; then
    echo "   OK: identiek aan de gepubliceerde versie."
    return 0
  fi
  echo "   WAARSCHUWING: de bundel op plof.app komt NIET overeen met de gepubliceerde hash."
  return 1
}

echo "Plof bundel-integriteitscontrole"
echo "================================="
echo
UITKOMST=0
controleer "Protocol 1: plof-pqc.js" "https://plof.app/?plof_openen_pqc_js=1" \
  "https://raw.githubusercontent.com/Plofapp/plof-integriteit/main/plof-pqc.integriteit.json" || UITKOMST=$?
echo
controleer "Protocol 2: plof-v2.js (ML-KEM-1024, ML-DSA-87, ratchet)" "https://plof.app/?plof_openen_v2_js=1" \
  "https://raw.githubusercontent.com/Plofapp/plof-integriteit/main/plof-v2.integriteit.json" || UITKOMST=$?
echo
if [ "$UITKOMST" = "0" ]; then
  echo "RESULTAAT: OK - beide bundels zijn identiek aan de gepubliceerde versies."
else
  echo "RESULTAAT: WAARSCHUWING - minstens één bundel wijkt af of kon niet worden gecontroleerd."
  echo "Vertrouw de versleuteling nu niet. Neem contact op met Plof en onderzoek dit."
fi
exit "$UITKOMST"
