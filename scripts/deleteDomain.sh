#!/bin/bash

# Function to return JSON response
json_response() {
    local status=$1
    local message=$2
    jq -n --argjson ok "$status" --arg message "$message" '{ok: $ok, message: $message}'
}

# Check if domain is provided
if [ -z "$1" ]; then
    json_response false "Usage: ./deleteDomain.sh <domain>"
    exit 1
fi

DOMAIN=$1

# Remove the domain configuration file
if ! rm -f /etc/nginx/conf.d/domains/$DOMAIN.conf; then
    json_response false "Failed to delete domain configuration."
    exit 1
fi

# Reload Nginx using the reload.sh script
RELOAD_OUTPUT=$(./reload.sh)
RELOAD_STATUS=$(echo "$RELOAD_OUTPUT" | jq -r '.ok')

if [[ $RELOAD_STATUS == "true" ]]; then
   json_response true "Domain $DOMAIN deleted successfully."
else
    # If reload fails, remove the domain configuration file
    rm -f /etc/nginx/conf.d/domains/$DOMAIN.conf
    json_response false "$(echo "$RELOAD_OUTPUT" | jq -r '.message')"
fi

