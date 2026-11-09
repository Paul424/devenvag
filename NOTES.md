# Notes

[20261109]

docker.io/envoyproxy/envoy:distroless-v1.39.6

gitlab/gitlab-gitaly-0:

Warning  FailedMount  4s (x8
 over 68s)  kubelet            MountVolume.SetUp failed for volume "custom-ca-certificates" : secret "root-ca" not found  

[20261106]

- Harbor ingress over traefik
- Gitlab:
        - externe pg
        - minio
        - redis

Bereikbaarheid voor clients
De hostnaam moet resolven vanaf je host (docker/skopeo), de minikube-node (containerd), en pods zoals GitLab-runners. De naam in externalURL moet overal hetzelfde IP geven. Gebruik daarvoor het MetalLB-IP van Traefik, met een CoreDNS hosts- of rewrite-regel in het cluster en /etc/hosts op de host en node.
CA-trust: zet de CA in /etc/docker/certs.d/harbor.dev.local/ (denk aan rootless Docker: ~/.config/docker/certs.d/), in de hosts.toml van containerd en in ~/.minikube/certs/.
Poort: Harbor draait op 443, dus je laat :5000 weg in je image-referenties.

curl -s -u "admin:admin" --cacert ./ca/harbor/ca.crt   'https://harbor.dev.local/api/v2.0/robots' | jq '.[]|select(.name=="robot$pusher")|.id'
ID=$(curl -s -u "admin:admin" --cacert ./ca/harbor/ca.crt   'https://harbor.dev.local/api/v2.0/robots' | jq '.[]|select(.name=="robot$pusher")|.id')
curl -s -o /dev/null -w '%{http_code}\n' -u 'robot$pusher:Frabar01' --cacert ./ca/harbor/ca.crt https://harbor.dev.local/v2/
curl -i -u "admin:admin" --cacert ./ca/harbor/ca.crt -H 'Content-Type: application/json' -X PATCH "https://harbor.dev.local/api/v2.0/robots/$ID" -d '{"secret":"Frabar01"}'
curl -s -o /dev/null -w '%{http_code}\n' -u 'robot$pusher:Frabar01'   --cacert ./ca/harbor/ca.crt https://harbor.dev.local/v2/

helm template harbor ./charts/harbor-1.19.4.tgz -f ./environments/base/harbor/common-harbor.yaml -f ./environments/base/harbor/secrets/common-harbor-secret.yaml -f ./environments/dev01/platform02/harbor/values-harbor.yaml -f ./environments/dev01/platform02/harbor/secrets/values-harbor-secret.yaml > ./logs/harbor

helm template gitlab ./charts/gitlab-10.5.4.tgz -f ./environments/base/gitlab/common-gitlab.yaml -f ./environments/base/gitlab/secrets/common-gitlab-secret.yaml -f ./environments/dev01/platform04/gitlab/values-gitlab.yaml -f ./environments/dev01/platform04/gitlab/secrets/values-gitlab-secret.yaml > ./logs/gitlab

gitlab.dev.local, minio.dev.local en kas.dev.local

helm template cnpg ./charts/cloudnative-pg-0.29.1.tgz -f ./environments/base/pg/common-cnpg.yaml -f ./environments/base/pg/secrets/common-cnpg-secret.yaml -f ./environments/dev01/platform04/pg/values-cnpg.yaml -f ./environments/dev01/platform04/pg/secrets/values-cnpg-secret.yaml > ./logs/cnpg

skopeo list-tags docker://ghcr.io/cloudnative-pg/postgresql | jq -r '.Tags[]' | grep -E '^17\.' | sort -V | tail -20


[20261105]

- Add Traefik to 01
- Configure Harbor (02) with vendpred images, ingress, etc...

[20261104]

minikube was unable to download 

            registry.dev.local:5000/k8s-minikube/kicbase:v0.0.51
docker pull registry.dev.local:5000/kicbase:v0.0.51

docker pull registry.dev.local:5000/kube-scheduler:v1.37.0
        host.minikube.internal:5000/kube-scheduler:v1.37.0' was not found; unable to add it to cache.

docker pull registry.dev.local:5000/kube-scheduler:v1.37.0

to download registry.dev.local:5000/kicbase:v0.0.51, b
docker pull registry.dev.local:5000/pause:3.10.2


 from="dir:/home/pbox/projects/devenvag/artifacts/transfer/quay.io/metallb/speaker:v0.9.6" to="docker://registry.dev.local:5000/quay.io/speaker:v0.9.6"

docker pull registry.dev.local:5000/quay.io/speaker:v0.9.6
