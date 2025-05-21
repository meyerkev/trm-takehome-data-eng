#!/bin/bash

# Usage: ./get_cert_fingerprints.sh <url>
# Example: ./get_cert_fingerprints.sh token.actions.githubusercontent.com

if [ -z "$1" ]; then
    echo "Usage: $0 <url>"
    echo "Example: $0 token.actions.githubusercontent.com"
    exit 1
fi

URL=$1

# Remove any https:// prefix if present
URL=${URL#https://}

echo "Getting certificate chain for $URL..."

# Get the certificate and its fingerprint directly, removing colons
openssl s_client -connect $URL:443 -servername $URL </dev/null 2>/dev/null \
    | openssl x509 -fingerprint -sha1 -noout | cut -d'=' -f2 | tr -d ':'