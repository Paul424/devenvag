#!/bin/bash
set -euxo pipefail

BASE=$(dirname $(dirname $(realpath $0)))

mkdir -p $BASE/ca/zot/client

# skopeo needs the ca.crt in a folder without key file (otherwise it expects a client crt)
cp $BASE/ca/root/ca.crt $BASE/ca/zot/client/ca.crt

# # CA
# if [ ! -f "$BASE/ca/zot/ca.key" ]; then
#     openssl genrsa -out $BASE/ca/zot/ca.key 4096
# else
#     echo "$BASE/ca/zot/ca.key already exists."
# fi

# if [ ! -f "$BASE/ca/zot/ca.crt" ]; then
#     openssl req -x509 -new -nodes -key $BASE/ca/zot/ca.key -sha256 -days 3650 \
#         -subj "/CN=Airgap Root CA" -out $BASE/ca/zot/ca.crt
# else
#     echo "$BASE/ca/zot/ca.crt already exists."
# fi

# Servercertificaat
if [ ! -f "$BASE/ca/zot/server.key" ]; then
    openssl genrsa -out $BASE/ca/zot/server.key 2048
else
    echo "$BASE/ca/zot/server.key already exists."
fi

if [ ! -f "$BASE/ca/zot/server.csr" ]; then
    openssl req -new -key $BASE/ca/zot/server.key -subj "/CN=registry.dev.local" -out $BASE/ca/zot/server.csr
else
    echo "$BASE/ca/zot/server.csr already exists."
fi

cat > $BASE/ca/zot/san.ext << 'EOF'
subjectAltName = DNS:host.minikube.internal, DNS:registry.dev.local, DNS:localhost
extendedKeyUsage = serverAuth
EOF

if [ ! -f "$BASE/ca/zot/server.crt" ]; then
    openssl x509 -req -in $BASE/ca/zot/server.csr -CA $BASE/ca/root/ca.crt -CAkey $BASE/ca/root/ca.key -CAcreateserial \
    -out $BASE/ca/zot/server.crt -days 825 -sha256 -extfile $BASE/ca/zot/san.ext
else
    echo "$BASE/ca/zot/server.crt already exists."
fi
