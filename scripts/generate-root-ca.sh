#!/bin/bash
set -euxo pipefail

BASE=$(dirname $(dirname $(realpath $0)))

mkdir -p $BASE/ca/root

# CA
if [ ! -f "$BASE/ca/root/ca.key" ]; then
    openssl genrsa -out $BASE/ca/root/ca.key 4096
else
    echo "$BASE/ca/root/ca.key already exists."
fi

if [ ! -f "$BASE/ca/root/ca.crt" ]; then
    openssl req -x509 -new -nodes -key $BASE/ca/root/ca.key -sha256 -days 3650 \
        -subj "/CN=Airgap Root CA" \
        -addext "basicConstraints=critical,CA:TRUE" \
        -addext "keyUsage=critical,keyCertSign,cRLSign" \
        -addext "subjectKeyIdentifier=hash" \
        -out $BASE/ca/root/ca.crt
else
    echo "$BASE/ca/root/ca.crt already exists."
fi
