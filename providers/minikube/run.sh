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

minikube ip

# minikube addons images metallb
minikube addons enable metallb \
  --images="Speaker=quay.io/metallb/speaker:v0.9.6,Controller=quay.io/metallb/controller:v0.9.6"

# minikube addons images csi-hostpath-driver
minikube addons enable csi-hostpath-driver \
  --images="\
HostMonitorController=registry.k8s.io/sig-storage/csi-external-health-monitor-controller:v0.7.0,\
NodeDriverRegistrar=registry.k8s.io/sig-storage/csi-node-driver-registrar:v2.6.0,\
HostPathPlugin=registry.k8s.io/sig-storage/hostpathplugin:v1.9.0,\
LivenessProbe=registry.k8s.io/sig-storage/livenessprobe:v2.8.0,\
Resizer=registry.k8s.io/sig-storage/csi-resizer:v1.6.0,\
Snapshotter=registry.k8s.io/sig-storage/csi-snapshotter:v6.1.0,\
Provisioner=registry.k8s.io/sig-storage/csi-provisioner:v3.3.0,\
Attacher=registry.k8s.io/sig-storage/csi-attacher:v4.0.0"

kubectl get nodes
