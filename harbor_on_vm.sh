#!/usr/bin/env bash
set -euo pipefail

# -------------------------------
# CONFIG
# -------------------------------
HARBOR_VERSION="2.11.0"
INSTALL_DIR="/opt/harbor"
CERT_DIR="/data/certs"

IP_ADDR="${1:-}"
if [[ -z "$IP_ADDR" ]]; then
    read -rp "Enter the IP address of this VM: " IP_ADDR
fi

HARBOR_PACKAGE="harbor-offline-installer-v${HARBOR_VERSION}.tgz"

# -------------------------------
# 1. Check offline package
# -------------------------------
if [[ ! -f "$HARBOR_PACKAGE" ]]; then
    echo "❌ Offline Harbor package $HARBOR_PACKAGE not found in current directory."
    echo "👉 Please download from:"
    echo "https://github.com/goharbor/harbor/releases/download/v${HARBOR_VERSION}/${HARBOR_PACKAGE}"
    exit 1
fi

# -------------------------------
# 2. Extract Harbor
# -------------------------------
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "📦 Extracting Harbor offline installer..."
    mkdir -p /opt
    tar xzf "$HARBOR_PACKAGE" -C /opt
    mv /opt/harbor /opt/harbor-${HARBOR_VERSION}
    ln -s /opt/harbor-${HARBOR_VERSION} $INSTALL_DIR
else
    echo "✅ Harbor directory already exists."
fi

# -------------------------------
# 3. Generate self-signed certs
# -------------------------------
mkdir -p "$CERT_DIR"

echo "🔐 Generating self-signed certificate for $IP_ADDR"

# CA
openssl genrsa -out "$CERT_DIR/ca.key" 4096
openssl req -x509 -new -nodes -sha512 -days 3650 \
    -subj "/C=US/ST=State/L=City/O=MyOrg/OU=IT/CN=$IP_ADDR" \
    -key "$CERT_DIR/ca.key" \
    -out "$CERT_DIR/ca.crt"

# Server key
openssl genrsa -out "$CERT_DIR/$IP_ADDR.key" 4096

cat > "$CERT_DIR/req.cnf" <<EOF
[ req ]
default_bits       = 4096
prompt             = no
default_md         = sha256
distinguished_name = dn
req_extensions     = req_ext

[ dn ]
C = US
ST = State
L = City
O = MyOrg
OU = IT
CN = $IP_ADDR

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
IP.1 = $IP_ADDR
DNS.1 = $IP_ADDR
EOF

# CSR
openssl req -new -key "$CERT_DIR/$IP_ADDR.key" -out "$CERT_DIR/$IP_ADDR.csr" -config "$CERT_DIR/req.cnf"

cat > "$CERT_DIR/v3.ext" <<EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[ alt_names ]
IP.1 = $IP_ADDR
DNS.1 = $IP_ADDR
EOF

# Sign cert
openssl x509 -req -sha512 -days 3650 \
    -CA "$CERT_DIR/ca.crt" -CAkey "$CERT_DIR/ca.key" -CAcreateserial \
    -in "$CERT_DIR/$IP_ADDR.csr" -out "$CERT_DIR/$IP_ADDR.crt" \
    -extfile "$CERT_DIR/v3.ext"

openssl x509 -inform PEM -in "$CERT_DIR/$IP_ADDR.crt" -out "$CERT_DIR/$IP_ADDR.cert"
# 4. Configure harbor.yml properly
# -------------------------------
HARBOR_YML="$INSTALL_DIR/harbor.yml"
cp "$INSTALL_DIR/harbor.yml.tmpl" "$HARBOR_YML"

# Set hostname
sed -i "s/^hostname:.*/hostname: $IP_ADDR/" "$HARBOR_YML"

# Delete existing https block (4 lines starting with https:)
sed -i '/^https:/,+3d' "$HARBOR_YML"

# Append new https block right after hostname
awk -v cert="$CERT_DIR/$IP_ADDR.crt" -v key="$CERT_DIR/$IP_ADDR.key" '
/^hostname:/ {
    print;
    print "https:";
    print "  port: 443";
    print "  certificate: " cert;
    print "  private_key: " key;
    next
}1' "$HARBOR_YML" > "$HARBOR_YML.tmp" && mv "$HARBOR_YML.tmp" "$HARBOR_YML"

echo "✅ Final harbor.yml https block:"
grep -A4 "^https:" "$HARBOR_YML"
# -------------------------------
cd "$INSTALL_DIR"
echo "🚀 Running Harbor prepare..."
./prepare
echo "📡 Installing Harbor..."
./install.sh

echo ""
echo "✅ Harbor installed successfully!"
echo "🌐 URL: https://$IP_ADDR"
echo "👤 Username: admin"
echo "🔑 Password: (check harbor.yml)"
echo ""
