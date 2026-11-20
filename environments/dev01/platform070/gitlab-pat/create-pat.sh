#!/bin/sh
set -euxo

TOKEN="glpat-$(head -c 64 /dev/urandom | base64 | tr -dc 'A-Za-z0-9' | head -c 20)"

kubectl -n gitlab exec deploy/gitlab-toolbox -c toolbox -- gitlab-rails runner "
  u = User.find_by_username('root') or abort('root ontbreekt')
  u.personal_access_tokens.where(name: 'crossplane').destroy_all
  t = u.personal_access_tokens.build(name: 'crossplane', scopes: [:api], expires_at: 364.days.from_now.to_date)
  t.set_token('$TOKEN')
  t.save!"

kubectl -n crossplane create secret generic gitlab-credentials \
  --from-literal=token="$TOKEN" --dry-run=client -o yaml | kubectl apply -f -

unset TOKEN
