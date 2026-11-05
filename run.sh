# #!/bin/bash
# set -euxo pipefail

# BASE=$(dirname $(dirname $(dirname $(realpath $0))))

# # Generate a self-signed CA certificate and private key for Keycloak
# bash $BASE/scripts/generate-keycloak-ca.sh

# # Have the docker daemon trust the zot registry (to pull the kicbase image)
# bash $BASE/scripts/generate-zot-ca.sh
# mkdir -p ~/.config/docker/certs.d/registry.dev.local:5000
# cp $BASE/ca/zot/ca.crt ~/.config/docker/certs.d/registry.dev.local:5000/ca.crt
# mkdir -p ~/.config/docker/certs.d/host.minikube.internal:5000
# cp $BASE/ca/zot/ca.crt ~/.config/docker/certs.d/host.minikube.internal:5000/ca.crt

# # Have the node trust the zot registry (to pull the control-plane images)
# mkdir -p ~/.minikube/files/var/lib/minikube/certs/keycloak
# cp $BASE/ca/keycloak/ca.crt ~/.minikube/files/var/lib/minikube/certs/keycloak/ca.crt

# minikube start \
#     --nodes=1 \
#     --driver=docker \
#     --container-runtime=docker \
#     --cpus=4 \
#     --memory=12384 \
#     --cni=calico \
#     --subnet=192.168.49.0/24 \
#     --extra-config=apiserver.oidc-issuer-url=https://keycloak.dev.local/realms/me-yoda \
#     --extra-config=apiserver.oidc-client-id=kubernetes \
#     --extra-config=apiserver.oidc-username-claim=preferred_username \
#     --extra-config=apiserver.oidc-username-prefix=- \
#     --extra-config=apiserver.oidc-groups-claim=groups \
#     --extra-config=apiserver.oidc-ca-file=/var/lib/minikube/certs/keycloak/ca.crt

# # minikube config set cpus 16
# # minikube config set memory 16384
# # minikube node add

# # minikube config set cpus 8
# # minikube config set memory 16384
# # minikube node add

# minikube ip
# minikube addons enable metallb
# # minikube addons configure metallb
# # minikube addons enable storage-provisioner
# minikube addons enable csi-hostpath-driver

# kubectl get nodes
