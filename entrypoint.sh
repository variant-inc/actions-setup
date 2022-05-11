#!/bin/bash

set -e
sudo git config --global --add safe.directory "$GITHUB_WORKSPACE"
sudo git clean -fdx

## Reference: https://github.com/GitTools/actions/
curl -sL https://raw.githubusercontent.com/GitTools/actions/main/dist/github/gitversion/execute/bundle.js -o gitversion-execute.js
node gitversion-execute.js
rm gitversion-execute.js

S_ORG=$(echo "$SONAR_ORGS" | jq -r ".[\"$GITHUB_REPOSITORY_OWNER\"]")
AWS_WEB_IDENTITY_TOKEN="$(cat "$AWS_WEB_IDENTITY_TOKEN_FILE")"
SONAR_ORG="${S_ORG:-$SONAR_ORG}"

echo "::add-mask::$SONAR_TOKEN"
echo "::add-mask::$OCTOPUS_CLI_API_KEY"
echo "::add-mask::$DOCKER_TOKEN"
echo "::add-mask::$AWS_WEB_IDENTITY_TOKEN"
echo "::add-mask::$LAZY_API_KEY"
echo "::add-mask::$LAZY_API_URL"
echo "::add-mask::$CONAN_KEY"
echo "::add-mask::$GITHUB_PACKAGES_TOKEN"

{
    echo "SONAR_TOKEN=$SONAR_TOKEN"
    echo "SONAR_ORG=$SONAR_ORG"
    echo "OCTOPUS_CLI_SERVER=$OCTOPUS_CLI_SERVER"
    echo "OCTOPUS_CLI_API_KEY=$OCTOPUS_CLI_API_KEY"
    echo "DOCKER_PASSWORD=$DOCKER_TOKEN"
    echo "AWS_ROLE_ARN=$AWS_ROLE_ARN"
    echo "AWS_WEB_IDENTITY_TOKEN=$AWS_WEB_IDENTITY_TOKEN"
    echo "LAZY_API_KEY=$LAZY_API_KEY"
    echo "LAZY_API_URL=$LAZY_API_URL"
    echo "CONAN_KEY=$CONAN_KEY"
    echo "CONAN_LOGIN_USERNAME=$CONAN_LOGIN_USERNAME"
    echo "GITHUB_PACKAGES_TOKEN=$GITHUB_PACKAGES_TOKEN"
    echo "GITHUB_TOKEN=$GITHUB_PACKAGES_TOKEN"
} >>"$GITHUB_ENV"
