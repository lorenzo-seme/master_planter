#!/bin/bash

# Sposta nella cartella del progetto backend
cd "$(dirname "$0")/backend/MasterPlanterApi" || exit 1

# Avvia il backend esponendolo su tutte le interfacce di rete
dotnet run --urls "http://0.0.0.0:5034"
