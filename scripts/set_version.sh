#!/bin/bash

set -e

declare GitVersion_preReleaseLabel
declare GitVersion_AssemblySemVer
declare GitVersion_NuGetVersion

versionNumber="${GitVersion_AssemblySemVer}"
if [ "${GitVersion_preReleaseLabel}" == "" ]; then
    versionNumber="${GitVersion_NuGetVersion}"
fi

{
    echo "IMAGE_VERSION=$versionNumber"
    echo "OCTOPUS_RELEASE_VERSION=$versionNumber"
} >>"$GITHUB_ENV"

{
    echo "image-version=$versionNumber"
} >>"$GITHUB_OUTPUT"
