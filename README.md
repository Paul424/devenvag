# Development Environment AG

This is just a small test to setup an airgapped development environment with tools like:
- gitlab + runners
- harbor

## Technical challenges

**Bootstrap using local / private registry**

1. Use [skopeo](https://github.com/podman-container-tools/skopeo) for prep'ing artifacts (charts / images) to disk and private registry
2. [Zot registry](https://zotregistry.dev/v2.1.23/) for an OCI compliant registry for images, charts and the initial bootstrap manifests (flux)
3. Minikube confs to ensure artifact loading from private registry

*learnings*

1. Zot using a docker container /w hostname defined by minicube (host.minikube.internal) only works in this single node setup. But it's also not relevant since minikube is only for this small demonstrator.

2. For a multi node cluster setup Ansible would be the best fit for peer-to-peer node level provisioning. Each node would run it's own zot registry, i.e. no complex LB / HA zot registry is required but at the same time bootstrap images should not be loaded from Harbor.

3. Multi node setup would best be done using Ansible.

**Jobs**

Jobs are used to setup harbor projects, gitlab repo / users and gitlab runners. It would be much better to manage this using an operator.

**HA Gitlab /w dependencies**

x

**Hardened images / scanning**

todo

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

## fs.inotify limits

```
sudo sysctl -w fs.inotify.max_user_watches=524288
sudo sysctl -w fs.inotify.max_user_instances=8192
```

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
192.168.49.100 gitlab.dev.local
```

## Sops setup (one time only)

To setup (once) see [sops setup guide](./docs/SOPS.md)

## Bootstrap

Bootstrap the registry (zot) and the minikube cluster
```
bash ./scripts/bootstrap.sh
```

## Push to harbor

Push artifacts (images and charts) into Harbor
```
bash ./scripts/vendor.sh push-to-harbor
```

## Push to gitlab

Push the platform repo into gitlab, which kicks off any kustomization on top of bootstrap layer
```
bash ./scripts/git.sh push-to-gitlab
```

## Access

1. [Traefik](https://traefik.dev.local/dashboard/#/)
2. [Harbor (admin/admin)](https://harbor.dev.local/harbor/projects)
3. [Seaweedfs (admin/admin)](https://admin.seaweedfs.dev.local/login)
4. [Gitlab (root/a312!Pw*.z,)](https://gitlab.dev.local/)
