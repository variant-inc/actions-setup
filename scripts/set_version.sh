#!/bin/bash

set -e

versionNumber="${GITVERSION_NUGETVERSION}"
{
    echo "IMAGE_VERSION=$versionNumber"
    echo "OCTOPUS_RELEASE_VERSION=$versionNumber"
} >>"$GITHUB_ENV"
