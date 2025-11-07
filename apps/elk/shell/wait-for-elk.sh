#!/bin/bash
set -euo pipefail

KIBANA_URL="http://192.168.10.152:5601/app/home"
MAX_RETRIES=60
SLEEP_SECONDS=5

echo "⏳ Attente de Kibana via test HTML sur /app/home..."

for i in $(seq 1 $MAX_RETRIES); do
  # Capture la page et le code HTTP
  RESPONSE=$(curl -sL --max-time 5 -w "%{http_code}" -o /tmp/kibana.html "$KIBANA_URL" || echo "000")
  CODE="${RESPONSE: -3}"  # les 3 derniers caractères = code HTTP

  if [ "$CODE" = "200" ]; then
    if ! grep -q "Kibana server is not ready yet" /tmp/kibana.html; then
      echo "✅ Kibana est prêt et l’interface est servie sans erreur."
      exit 0
    else
      echo "🔄 Tentative $i/$MAX_RETRIES : HTML reçu mais Kibana indique qu’il n’est pas prêt..."
    fi
  else
    echo "🔄 Tentative $i/$MAX_RETRIES : HTTP $CODE, Kibana pas encore prêt..."
  fi

  sleep $SLEEP_SECONDS
done

echo "❌ Échec : Kibana n’est pas prêt après $((MAX_RETRIES * SLEEP_SECONDS)) secondes."
exit 1
