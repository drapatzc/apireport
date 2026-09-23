#!/bin/bash
# Doppelklick startet Store Reports und oeffnet danach die Uebersicht im Browser.
cd "$(dirname "$0")" || exit 1
./storereports --open
echo
read -n 1 -s -r -p "Fertig – beliebige Taste drücken zum Schließen …"
echo
