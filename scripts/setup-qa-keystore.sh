#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS="$ROOT/.secrets"
KEYSTORE="$SECRETS/qa.keystore"
PROPS="$ROOT/qa-signing.properties"
mkdir -p "$SECRETS"
chmod 700 "$SECRETS"

if [[ -f "$KEYSTORE" || -f "$PROPS" ]]; then
  echo "Refusing to overwrite existing QA signing material." >&2
  echo "Keystore: $KEYSTORE" >&2
  echo "Properties: $PROPS" >&2
  exit 2
fi
command -v keytool >/dev/null 2>&1 || { echo "ERROR: keytool (JDK) required." >&2; exit 2; }

PASSWORD="${QA_KEYSTORE_PASSWORD:-$(python3 - <<'PY2'
import secrets
print(secrets.token_urlsafe(24))
PY2
)}"
ALIAS="qa"

keytool -genkeypair -v \
  -keystore "$KEYSTORE" \
  -storepass "$PASSWORD" \
  -keypass "$PASSWORD" \
  -alias "$ALIAS" \
  -keyalg RSA -keysize 3072 -validity 10000 \
  -dname "CN=Agentic Android QA, OU=QA, O=Local, L=Local, ST=Local, C=XX"

cat > "$PROPS" <<EOF
storeFile=.secrets/qa.keystore
storePassword=$PASSWORD
keyAlias=$ALIAS
keyPassword=$PASSWORD
EOF
chmod 600 "$PROPS" "$KEYSTORE"
echo "Persistent QA signing configured. Back up .secrets/qa.keystore and qa-signing.properties securely."
