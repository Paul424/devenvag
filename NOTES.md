# Notes

[20261106]

- Harbor ingress over traefik
- 

Bereikbaarheid voor clients
De hostnaam moet resolven vanaf je host (docker/skopeo), de minikube-node (containerd), en pods zoals GitLab-runners. De naam in externalURL moet overal hetzelfde IP geven. Gebruik daarvoor het MetalLB-IP van Traefik, met een CoreDNS hosts- of rewrite-regel in het cluster en /etc/hosts op de host en node.
CA-trust: zet de CA in /etc/docker/certs.d/harbor.dev.local/ (denk aan rootless Docker: ~/.config/docker/certs.d/), in de hosts.toml van containerd en in ~/.minikube/certs/.
Poort: Harbor draait op 443, dus je laat :5000 weg in je image-referenties.


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
