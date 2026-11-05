#!/bin/bash
set -euxo pipefail
# set -euo pipefail

BASE=$(dirname $(dirname $(realpath $0)))
if [[ "${1:-}" == "pull" ]]; then
  # Have skopeo pull all the images listed in artifacts/images.yaml and store them in artifacts/transfer 
  # while keeping metadata.
  # @todo: login using PAT?
  skopeo sync --all --scoped --src yaml --dest dir $BASE/artifacts/images.yaml $BASE/artifacts/transfer

elif [[ "${1:-}" == "push" ]]; then
  # Have skopeo push all the images listed in artifacts/images.yaml from artifacts/transfer to the airgapped registry. We walk the dir here to
  # maintain the registry and optional image prefix / path.
  while IFS= read -r -d '' manifest; do
    dir="$(dirname "$manifest")"
    ref="${dir#"$BASE/artifacts/transfer"/}"

    if [[ "$ref" == "$dir" || "$ref" != *[:@]* ]]; then
      echo "skip $dir"
      continue
    fi

    dest="docker://registry.dev.local:5000/$ref"
    echo "- $ref ==> $dest"
    skopeo copy --all "dir:$dir" "$dest"
  done < <(find "$BASE/artifacts/transfer" -name manifest.json -print0 | sort -z)
  
  # patch image paths since we cannot tweak them in minikube
  skopeo copy --all "docker://registry.dev.local:5000/registry.k8s.io/kube-apiserver:v1.37.0" "docker://registry.dev.local:5000/kube-apiserver:v1.37.0"
  skopeo copy --all "docker://registry.dev.local:5000/gcr.io/k8s-minikube/storage-provisioner:v5" "docker://registry.dev.local:5000/k8s-minikube/storage-provisioner:v5"
  skopeo copy --all "docker://registry.dev.local:5000/registry.k8s.io/etcd:3.7.0-0" "docker://registry.dev.local:5000/etcd:3.7.0-0"
  skopeo copy --all "docker://registry.dev.local:5000/registry.k8s.io/kube-scheduler:v1.37.0" "docker://registry.dev.local:5000/kube-scheduler:v1.37.0"
  skopeo copy --all "docker://registry.dev.local:5000/registry.k8s.io/kube-proxy:v1.37.0" "docker://registry.dev.local:5000/kube-proxy:v1.37.0"
  skopeo copy --all "docker://registry.dev.local:5000/registry.k8s.io/pause:3.10.2" "docker://registry.dev.local:5000/pause:3.10.2"
  skopeo copy --all "docker://registry.dev.local:5000/registry.k8s.io/coredns/coredns:v1.14.6" "docker://registry.dev.local:5000/coredns:v1.14.6"
  skopeo copy --all "docker://registry.dev.local:5000/registry.k8s.io/kube-controller-manager:v1.37.0" "docker://registry.dev.local:5000/kube-controller-manager:v1.37.0"
fi
