# Plof — onafhankelijke bundel-integriteit

Deze repository publiceert de integriteitshash van de **Plof post-quantum crypto-bundel** (`plof-pqc.js`) op een plek die **losstaat van de plof.app-webserver**.

## Waarom deze repository bestaat

De versleuteling van Plof gebeurt in de browser van de gebruiker, met code (`plof-pqc.js`) die van de plof.app-server wordt geladen. De hele belofte "de server ziet je post nooit leesbaar" rust op de aanname dat die code de échte, onaangetaste versleutelingscode is.

Als iemand de plof.app-server zou overnemen, zou die de bundel kunnen vervangen door een kwaadaardige versie. Om dat detecteerbaar te maken, publiceren we de hash van de juiste bundel **hier op GitHub** — een apart systeem, met een aparte inlog. Een aanvaller zou dan zowel de webserver als dit GitHub-account moeten compromitteren om onopgemerkt te blijven.

## Wat hier staat

- **`plof-pqc.integriteit.json`** — de canonieke hash (SHA-256 en SRI/SHA-384) van de huidige bundel, met versie en datum.
- **`verifieer-plof-bundel.sh`** — een scriptje dat de live bundel bij plof.app ophaalt, hasht, en vergelijkt met de hash hierboven.

## Zelf verifiëren

```bash
bash verifieer-plof-bundel.sh
```

Of handmatig:

```bash
curl -s 'https://plof.app/?plof_openen_pqc_js=1' | sha256sum
```

Vergelijk de uitkomst met het veld `sha256` in `plof-pqc.integriteit.json`. Gelijk = goed. Verschillend = niet vertrouwen, onderzoeken.

## Eerlijke beperking

Dit is een **detectiemechanisme**, geen volledige garantie. Een browser-app die van een server wordt geladen, kan door een volledig gecompromitteerde server in principe worden gemanipuleerd vóórdat verificatiecode draait. Volledige bescherming vereist een native app of browser-extensie (die niet elke keer vers van de server laadt). Deze publicatie maakt stille manipulatie wél veel moeilijker en detecteerbaar, en vormt een auditbaar anker voor de beveiligingsdocumentatie van Plof.
