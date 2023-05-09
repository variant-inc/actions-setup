#!/bin/bash

set -e

for var in "$@"
do
    DIR="$(dirname "${var}")"
    sh -c "set -e; cd '$DIR' && action-docs -u"
done
