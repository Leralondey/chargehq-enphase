#!/bin/bash

# v1.0 - Working with 7x Firmware version. The BC command is not supported by Synology and has been replaced by awk.

# Configuration
chargehq_uri='https://api.chargehq.net/api/public/push-solar-data'

# Add Charge HQ api_key and envoy ip below and log_file_path location

api_key='ac5cb156-e8be-4173-8534-e3e898ff96fd'             # Get this from Charge HQ Application
envoy_username=''      # Your login username for Enphase
envoy_password=''      # Your login password for Enphase
envoy_serial_number='' # Your serial number for Enphase
envoy_local_ip=''      # Your local IP address for Enphase
log_file_path='/dev/null'       # Log file cancelled to avoid overloading the disk, use the value below if necessary
## log_file_path='./chargehq.log'       # Log Location - easy for troubleshooting

# Function to obtain JWT token
get_jwt_token() {
  echo "$(date "+%Y-%m-%d %H:%M:%S") Executing get_jwt_token()" >> "$log_file_path"
  session_id=$(curl -sX POST "https://enlighten.enphaseenergy.com/login/login.json?" -F "user[email]=$envoy_username" -F "user[password]=$envoy_password" | jq -r ".session_id")
  jwt_token=$(curl -sX POST "https://entrez.enphaseenergy.com/tokens" -H "Content-Type: application/json" -d "{\"session_id\": \"$session_id\", \"serial_num\": \"$envoy_serial_number\", \"username\": \"$envoy_username\"}")
}

# Function to push data to Charge HQ
push_to_chargeHQ() {
  JSON_payload="{\"apiKey\":\"$api_key\",\"siteMeters\":{\"imported_kwh\":\"$imported_kwh\",\"exported_kwh\":\"$exported_kwh\",\"net_import_kw\":\"$net_import_kw\",\"consumption_kw\":\"$consumption_kw\",\"production_kw\":\"$production_kw\"}}"
  echo "$JSON_payload" >> "$log_file_path"
  curl -sX POST -H "Content-Type: application/json" -d "$JSON_payload" "$chargehq_uri" >/dev/null
  echo "$(date "+%Y-%m-%d %H:%M:%S") Pushed to Charge HQ" >> "$log_file_path"
}

# Initial JWT token retrieval
get_jwt_token

# Main script loop
while true; do

  envoycontent=$(curl -ks -H 'Accept: application/json' -H "Authorization: Bearer $jwt_token" "https://$envoy_local_ip/production.json?details=1" -b cookie -c cookie)

  if [ $? -ne 0 ] || [ -z "$envoycontent" ]; then
    echo "$(date "+%Y-%m-%d %H:%M:%S") Failed to obtain envoycontent. Refreshing JWT token..." >> "$log_file_path"
    get_jwt_token
    continue
  fi

  production_kw=$(jq -r '.production[1].wNow/1000 | if . < 0 then 0 else . end' <<<"${envoycontent}")
  consumption_kw=$(jq -r '.consumption[0].wNow/1000' <<<"${envoycontent}")
  net_import_kw=$(awk -v c="$consumption_kw" -v p="$production_kw" 'BEGIN{printf "%.6f", c-p}')

  if [ $(awk 'BEGIN{ print ('"$net_import_kw"' < 0) ? "1" : "0" }') -eq 1 ]; then
    imported_kwh=0
    exported_kwh=$(awk -v n="$net_import_kw" 'BEGIN{printf "%.6f", n*-1}')
  else
    imported_kwh=$net_import_kw
    exported_kwh=0
  fi

  push_to_chargeHQ

  sleep 30 #Will upload data every 30 seconds
done
