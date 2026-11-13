#!/bin/bash
set -euxo pipefail
# set -euo pipefail

BASE=$(dirname $(dirname $(realpath $0)))
if [[ "${1:-}" == "push-to-gitlab" ]]; then

  ######################################################################################
  # Push the platform repo into gitlab
  #

  # Establish trust by refering to the root CA that Harbor is using (which is exposed to a public endpoint using trust-manager)
  mkdir -p $BASE/ca/gitlab
  curl -sk https://192.168.49.2:8443/api/v1/namespaces/kube-public/configmaps/gitlab-root-ca \
    | jq -r '.data["ca.crt"]' > $BASE/ca/gitlab/ca.crt
  cat $BASE/ca/gitlab/ca.crt
  if ! git remote get-url gitlab >/dev/null 2>&1; then
    git remote add gitlab https://gitlab.dev.local/platform/devenvag.git
  fi
  git config http.https://gitlab.dev.local/.sslCAInfo "$BASE/ca/gitlab/ca.crt"
  git config credential.https://gitlab.dev.local.username pushr
  # git config credential.helper 'cache --timeout=28800'
  git -c credential.helper= \
    -c "credential.helper=!f() { echo username=pushr; echo password=$(kubectl -n env get secret gitlab-pushr-auth -o jsonpath='{.data.password}' | base64 -d); }; f" \
    push gitlab main
fi
