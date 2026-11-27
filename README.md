# Plof — onafhankelijke bundel-integriteit

Deze repository publiceert de integriteitshashes van de **Plof crypto-bundels**: `plof-pqc.js` (protocol 1) en `plof-v2.js` (protocol 2: ML-KEM-1024, ML-DSA-87, ratchet) op een plek die **losstaat van de plof.app-webserver**.

## Waarom deze repository bestaat

De versleuteling van Plof gebeurt in de browser van de gebruiker, met code (`plof-pqc.js`) die van de plof.app-server wordt geladen. De hele belofte "de server ziet je post nooit leesbaar" rust op de aanname dat die code de échte, onaangetaste versleutelingscode is.

Als iemand de plof.app-server zou overnemen, zou die de bundel kunnen vervangen door een kwaadaardige versie. Om dat detecteerbaar te maken, publiceren we de hash van de juiste bundel **hier op GitHub** — een apart systeem, met een aparte inlog. Een aanvaller zou dan zowel de webserver als dit GitHub-account moeten compromitteren om onopgemerkt te blijven.

## Wat hier staat

- **`plof-pqc.integriteit.json`** — de canonieke hash (SHA-256 en SRI/SHA-384) van de protocol-1-bundel, met versie en datum.
- **`plof-v2.integriteit.json`** — idem voor de protocol-2-bundel (`https://plof.app/?plof_openen_v2_js=1`), met de commit van Plof Core waaruit hij is gebouwd.
- **`verifieer-plof-bundel.sh`** — een scriptje dat beide live bundels bij plof.app ophaalt, hasht, en vergelijkt met de hashes hierboven.

## Zelf verifiëren

```bash
bash verifieer-plof-bundel.sh
```

Of handmatig:

```bash
curl -s 'https://plof.app/?plof_openen_pqc_js=1' | sha256sum
curl -s 'https://plof.app/?plof_openen_v2_js=1' | sha256sum
```

Vergelijk de uitkomsten met het veld `sha256` in `plof-pqc.integriteit.json` en `plof-v2.integriteit.json`. Gelijk = goed. Verschillend = niet vertrouwen, onderzoeken.

## Eerlijke beperking

Dit is een **detectiemechanisme**, geen volledige garantie. Een browser-app die van een server wordt geladen, kan door een volledig gecompromitteerde server in principe worden gemanipuleerd vóórdat verificatiecode draait. Volledige bescherming vereist een native app of browser-extensie (die niet elke keer vers van de server laadt). Deze publicatie maakt stille manipulatie wél veel moeilijker en detecteerbaar, en vormt een auditbaar anker voor de beveiligingsdocumentatie van Plof.
