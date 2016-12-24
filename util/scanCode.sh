#!/usr/bin/env bash

set -o noglob
scan='grep --exclude-dir=node_modules --exclude-dir=deps -rL --exclude *~ --exclude *.json --exclude *.run --exclude *.md --exclude *.pyc --exclude .* Copyright .'

if [ `${scan} | wc -l` != 0 ]; then
    echo "Failure. These files do no have a copyright notice:"
    (${scan})
    exit 1
fi
