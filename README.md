# Development Environment AG

This is just a small test to setup an airgapped development environment with tools like:
- gitlab + runners
- harbor

## Todo's

- flux toevoegen met kustomize en environment tegen zot oci; dus een cluster artifact publiceren
- Add harbor /w preconfigured secret
- kip ei probleem; harbor liefst met chart, vereist flux vereist git, git komt pas met gitlab...
- 


## Technical challenges

**Bootstrap using local / private registry**

1. Use [skopeo](https://github.com/podman-container-tools/skopeo) for prep'ing artifacts (charts / images) to disk and private registry
2. [Zot registry](https://zotregistry.dev/v2.1.23/) for a temp. OCI compliant registry
3. minikube confs to ensure artifact loading from private registry

*learnings*

1. Zot using a docker container /w hostname defined by minicube (host.minikube.internal) only works in this single node setup.

    For a multi node cluster setup i would use a dedicated bootstrap machine which runs zot using a daemon and make it reachable through a dns server / netw routing.

2. A zot registry should not be temporarily but permanent but only for bootstrap images, where bootstrapping means up to the point where harbor is running and can take over.

**HA Gitlab /w dependencies**

x

**Hardened images / scanning**

x

## Prerequisites

1. [docker](https://docs.docker.com/engine/install/ubuntu/)
2. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
3. [kubelogin plugin](https://github.com/int128/kubelogin/releases)
4. [minikube](https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download)
5. [flux](https://fluxcd.io/flux/installation/)
6. [sops](https://getsops.io/docs/installation/)
7. [git](./docs/GIT.md)
8. [VSCode](https://code.visualstudio.com/thank-you?dv=linux64_deb&build=stable)
9. [k9s](https://github.com/derailed/k9s/releases)
10. [yq](https://github.com/mikefarah/yq/releases/tag/v4.54.1)
11. [skopeo](https://github.com/podman-container-tools/skopeo/blob/main/install.md)
12. [zot registry](https://zotregistry.dev/v2.1.23/install-guides/install-guide-linux/#before-you-begin)

## Pull images

Artifacts need to be vendored to a local repository. This step only pulls the artifacts and is done seperately since it requires an internet connection.

```
bash ./scripts/vendor.sh pull
<...>
INFO[0292] Synced 13 images from 13 sources
```

## DNS patch

```
127.0.0.1 registry.dev.local
127.0.0.1 host.minikube.internal
192.168.49.100 traefik.dev.local
192.168.49.100 harbor.dev.local

```

## Sops setup (one time only)

To setup (once) see [sops setup guide](./docs/SOPS.md)

## Bootstrap

Bootstrap the registry (zot) and the minikube cluster
```
bash ./scripts/bootstrap.sh 
```

## Add trust for Harbor

Extract the CA and add to truststore

## Push to harbor

