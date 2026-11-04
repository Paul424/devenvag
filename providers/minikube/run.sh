#!/bin/bash
set -euxo pipefail

BASE=$(dirname $(dirname $(dirname $(realpath $0))))

# Generate a self-signed CA certificate and private key for Keycloak
bash $BASE/scripts/generate-keycloak-ca.sh

# Move the crt into a fixed folder which is mounted into the control-plane container by default
mkdir -p ~/.minikube/files/var/lib/minikube/certs
cp $BASE/ca/keycloak/ca.crt ~/.minikube/files/var/lib/minikube/certs/keycloak-ca.crt

# Have kubelet trust the zot registry
mkdir -p ~/.minikube/files/etc/containerd/certs.d/host.minikube.internal:5000
cp $BASE/ca/zot/ca.crt ~/.minikube/files/etc/containerd/certs.d/host.minikube.internal:5000/ca.crt

mkdir -p ~/.minikube/files/etc/containerd/certs.d/host.minikube.internal:5000
cat > ~/.minikube/files/etc/containerd/certs.d/host.minikube.internal:5000/hosts.toml <<'EOF'
server = "https://host.minikube.internal:5000"

[host."https://host.minikube.internal:5000/v2/"]
  capabilities = ["pull", "resolve"]
  override_path = true
  ca = "/etc/containerd/certs.d/host.minikube.internal:5000/ca.crt"
EOF

minikube start \
    --nodes=1 \
    --driver=docker \
    --container-runtime=containerd \
    --base-image=registry.dev.local:5000/gcr.io/kicbase:v0.0.51 \
    --image-repository=host.minikube.internal:5000 \
    --cpus=4 \
    --memory=16384 \
    --cni=calico \
    --subnet=192.168.49.0/24 \
    --extra-config=apiserver.oidc-issuer-url=https://keycloak.devenv.local/realms/me-yoda \
    --extra-config=apiserver.oidc-client-id=kubernetes \
    --extra-config=apiserver.oidc-username-claim=preferred_username \
    --extra-config=apiserver.oidc-username-prefix=- \
    --extra-config=apiserver.oidc-groups-claim=groups \
    --extra-config=apiserver.oidc-ca-file=/var/lib/minikube/certs/keycloak-ca.crt

    # --insecure-registry="registry.dev.local:5000" \
# 

minikube ip
minikube addons enable metallb
minikube addons enable csi-hostpath-driver

kubectl get nodes
