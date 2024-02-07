#!/bin/bash

set -e

echo "$@"
for var in "$@"; do
	DIR="$(dirname "${var}")"
	sh -c "set -e; cd '$DIR' && action-docs -u"
done
