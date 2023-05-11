#!/bin/bash

set -e

versionNumber="${GITVERSION_ASSEMBLYSEMVER}"
if [ "${GITVERSION_PRERELEASELABEL}" == "" ]; then
    versionNumber="${GITVERSION_NUGETVERSION}"
fi

{
    echo "IMAGE_VERSION=$versionNumber"
    echo "OCTOPUS_RELEASE_VERSION=$versionNumber"
} >>"$GITHUB_ENV"

{
    echo "image-version=$versionNumber"
} >>"$GITHUB_OUTPUT"
