#!/bin/bash

ENDPOINT="http://172.233.4.110/api/healthz"
HOST_HEADER="api.myapp.lat"

declare -A PROBES=(
  [brazil_sao_paulo]="curlip.com"
  [chile_santiago]="curlip.com"
  [colombia_bogota]="curlip.com"
  [mexico_mexico_city]="curlip.com"
  [argentina_buenos_aires]="curlip.com"
  [usa_dallas]="curlip.com"
)

for region in "${!PROBES[@]}"; do
  echo "🌎 Testing from: $region"
  curl -s -H "Host: $HOST_HEADER" --resolve "$HOST_HEADER:80:$ENDPOINT" "http://${PROBES[$region]}/curl?url=$ENDPOINT" \
    -w "\nConnect: %{time_connect}s\nTotal: %{time_total}s\n" \
    -o /dev/null
  echo "---------------------------------------------"
done
