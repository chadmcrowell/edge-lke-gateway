#!/bin/bash

ENDPOINT="http://172.233.4.110/api/healthz"
HOST_HEADER="api.myapp.lat"

# Define regions and endpoints as parallel arrays
REGIONS=(
  "Brazil_Sao_Paulo"
  "Chile_Santiago"
  "Colombia_Bogota"
  "Mexico_MexicoCity"
  "Argentina_BuenosAires"
  "USA_Dallas"
)

PROXIES=(
  "curlip.com"
  "curlip.com"
  "curlip.com"
  "curlip.com"
  "curlip.com"
  "curlip.com"
)

for i in "${!REGIONS[@]}"; do
  REGION="${REGIONS[$i]}"
  PROXY="${PROXIES[$i]}"

  echo "🌎 Testing from: $REGION"
  curl -s -H "Host: $HOST_HEADER" "http://${PROXY}/curl?url=$ENDPOINT" \
    -w "\nConnect: %{time_connect}s\nTotal: %{time_total}s\n" \
    -o /dev/null
  echo "---------------------------------------------"
done
