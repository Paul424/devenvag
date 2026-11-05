#!/bin/bash

set -euo pipefail

BASE=$(dirname "$(dirname "$(realpath "$0")")")
ENVIRONMENTS="$BASE/environments"
cd "$BASE"

while IFS= read -r -d '' f; do
    filename=${f##*/}

    if [[ "$filename" == "kustomization.yaml" || "$filename" == "kustomization.yml" ]]; then
        echo "Skip $f"
        continue
    fi

    if [[ "$filename" == *-enc.yaml || "$filename" == *-enc.yml ]]; then
        echo "Skip $f"
        continue
    fi

    of="${f%.*}-enc.yaml"
    echo "Encrypt $f -> $of"

    sops --encrypt "$f" > "$of"

done < <(find "$ENVIRONMENTS" -type f \
    \( -name '*.yaml' -o -name '*.yml' \) \
    -path '*/secrets/*' -print0 | sort -z)
