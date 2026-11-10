# Notes

[20261110]

jq -nc --arg p Gritlab01 '{name:"Flux",username:"flux",email:"flux@dev.local",password:$p,skip_confirmation:true,can_create_group:false}'                                                                │

api -X POST http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/api/v4/users -d '{"name":"Flux","username":"flux","email":"flux@dev.local","password":"Gritlab01","skip_confirmation":true,"c │

curl -sS -H 'PRIVATE-TOKEN: glpat-JbPKIkAIssgqN5EitvFNNOvui8' -H 'Content-Type: application/json' -X POST http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/api/v4/users -d '{"name":"Flux","username":"flux","email":"flux@dev.local","password":"Gritlab01","skip_confirmation":true,"can_create_group":false}'

│ gitlab-bootstrap-cg4v7 Failed to create user         

 gitlab-bootstrap-hc52p + EXP=2027-11-09                                                                                                                                                                                           │
│ gitlab-bootstrap-hc52p + api -X POST http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/api/v4/users/3/personal_access_tokens -d '{"name":"fluxr","scopes":["read_repository"],"expires_at":"2027-11-09"}'            │
│ gitlab-bootstrap-hc52p + curl -sS -H 'PRIVATE-TOKEN: glpat-fnqkHY6zBiBq4UrzYEgRUNsPAG' -H 'Content-Type: application/json' -X POST http://gitlab-webservice-default.gitlab.svc.cluster.local:8181/api/v4/users/3/personal_access_ │
│ tokens -d '{"name":"fluxr","scopes":["read_repository"],"expires_at":"2027-11-09"}
│ gitlab-bootstrap-hc52p + jq -r .token

env                   platform04            False            Secret/gitlab/gitlab-redis-password not found: namespaces "gitlab" not foundNamespace/cnpg-system createdNamespace/seaweedfs created  

                                                                                                                                                                                                                             │
│ 2026-11-10T11:53:17.699345977Z: applying CustomResourceDefinition(s) with policy Create: {}                                                                                                                                       │
│   Warning  InstallFailed  5m36s  helm-controller  Helm install failed for release gitlab/gitlab with chart gitlab@10.5.4: unable to build kubernetes objects from release manifest: [resource mapping not found for name: "gitlab │
│ -gw" namespace: "gitlab" from "": no matches for kind "Gateway" in version "gateway.networking.k8s.io/v1"                                                                                                                  

curl -u "admin:admin" -H 'Content-Type: application/json' -XGET http://harbor-core.harbor.svc.cluster.local/api/v2.0/robots?q=name%3Drobot%24pusher&page_size=100





              set -euxo
              HARBOR_URL=
              ROBOT_PUSHER=pusher
              FULLNAME_PUSHER='robot$pusher'
              ROBOT_PULLER=puller
              FULLNAME_PULLER='robot$puller'

              # code-only (POST/PATCH)
              call() { # method path body
                curl -s -o /dev/null -w '%{http_code}' -u "admin:$PASS" \
                  -H 'Content-Type: application/json' -X "$1" "$HARBOR_URL$2" -d "$3"
              }
              # body terug (GET)
              get() { curl -sf -u "admin:$PASS" "$HARBOR_URL$1"; }
              ok() { case "$1" in 200|201|409) echo "$2: ok ($1)";; *) echo "$2: failed ($1)"; exit 1;; esac; }

              for p in registry.k8s.io gcr.io quay.io ghcr.io docker.io charts; do
                ok "$(call POST /api/v2.0/projects "{\"project_name\":\"$p\",\"public\":false}")" "project $p"
              done

              # robot aanmaken zonder secret (409 = bestaat al)
              ok "$(call POST /api/v2.0/robots '{
                "name":"'"$ROBOT_PUSHER"'","level":"system","duration":-1,
                "permissions":[{"kind":"project","namespace":"*",
                  "access":[{"resource":"repository","action":"push"},
                            {"resource":"repository","action":"pull"}]}]}')" "robot $ROBOT_PUSHER"

              ID=$(get "/api/v2.0/robots?q=name%3Drobot%24pusher&page_size=100" \
                | jq -r --arg n "$FULLNAME_PUSHER" '.[] | select(.name==$n) | .id' | head -1)
              [ -n "$ID" ] || { echo "robot-id not found"; exit 1; }

              # secret expliciet zetten; 200 is het enige geldige resultaat
              BODY=$(jq -nc --arg s "$ROBOT_PUSHER_SECRET" '{secret:$s}')
              code=$(call PATCH "/api/v2.0/robots/$ID" "$BODY")
              [ "$code" = 200 ] || { echo "failed to set secret: ($code)"; exit 1; }
              echo "secret set for robot id=$ID"

              # robot aanmaken zonder secret (409 = bestaat al)
              ok "$(call POST /api/v2.0/robots '{
                "name":"'"$ROBOT_PULLER"'","level":"system","duration":-1,
                "permissions":[{"kind":"project","namespace":"*",
                  "access":[{"resource":"repository","action":"pull"}]}]}')" "robot $ROBOT_PULLER"

              ID=$(get "/api/v2.0/robots?q=name%3Drobot%24puller&page_size=100" \
                | jq -r --arg n "$FULLNAME_PULLER" '.[] | select(.name==$n) | .id' | head -1)
              [ -n "$ID" ] || { echo "robot-id not found"; exit 1; }

              # secret expliciet zetten; 200 is het enige geldige resultaat
              BODY=$(jq -nc --arg s "$ROBOT_PULLER_SECRET" '{secret:$s}')
              code=$(call PATCH "/api/v2.0/robots/$ID" "$BODY")
              [ "$code" = 200 ] || { echo "failed to set secret: ($code)"; exit 1; }
              echo "secret set for robot id=$ID"


[20261109]

docker.io/envoyproxy/envoy:distroless-v1.39.6

gitlab/gitlab-gitaly-0:

Warning  FailedMount  4s (x8
 over 68s)  kubelet            MountVolume.SetUp failed for volume "custom-ca-certificates" : secret "root-ca" not found  

image: registry.gitlab.com/gitlab-org/build/cng/certificates:v19.5.3    
image: "registry.gitlab.com/gitlab-org/build/cng/gitlab-base:v19.5.3"                    
image: "registry.gitlab.com/gitlab-org/build/cng/gitlab-exporter:17.0.2"                    
image: "registry.gitlab.com/gitlab-org/build/cng/gitlab-shell:v14.58.0"                    
image: "registry.gitlab.com/gitlab-org/build/cng/gitlab-kas:v19.5.3"                    
image: "registry.gitlab.com/gitlab-org/build/cng/gitlab-sidekiq-ce:v19.5.3"                    
image: "registry.gitlab.com/gitlab-org/build/cng/gitlab-workhorse-ce:v19.5.3"          
image: "registry.gitlab.com/gitlab-org/build/cng/gitaly:v19.5.3"                    
image: registry.gitlab.com/gitlab-org/build/cng/kubectl:v19.5.3
image: "registry.gitlab.com/gitlab-org/build/cng/gitlab-toolbox-ce:v19.5.3"
image: registry.gitlab.com/gitlab-org/build/cng/gitlab-webservice-ce:v19.5.3
        
- gitlab aanmaken repo devenvag
- aanmaken local account met een PAT
  met deze PAT kan ik namelijk de kustomizations inschakelen NA de bootstrap
- hieronder kan dan vallen mattermost en keycloak bijvoorbeeld
- gitlab runners
- gitlab shell
- en wat is kas?


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
