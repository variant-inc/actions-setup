#!/bin/bash

set -e
sudo git clean -fdx
## Reference: https://github.com/GitTools/actions/
curl -sL https://raw.githubusercontent.com/GitTools/actions/main/dist/github/gitversion/execute/bundle.js -o gitversion-execute.js
node gitversion-execute.js
rm gitversion-execute.js

echo "::add-mask::$SONAR_TOKEN"
echo "::add-mask::$OCTOPUS_CLI_API_KEY"
echo "::add-mask::$DOCKER_TOKEN"
{
  echo "SONAR_TOKEN=$SONAR_TOKEN"
  echo "SONAR_ORG=$SONAR_ORG"
  echo "OCTOPUS_CLI_SERVER=$OCTOPUS_CLI_SERVER"
  echo "OCTOPUS_CLI_API_KEY=$OCTOPUS_CLI_API_KEY"
  echo "DOCKER_PASSWORD=$DOCKER_TOKEN"
} >>"$GITHUB_ENV"

echo "AWS_ROLE_ARN=$AWS_ROLE_ARN" >>"$GITHUB_ENV"
AWS_WEB_IDENTITY_TOKEN="$(cat "$AWS_WEB_IDENTITY_TOKEN_FILE")"
echo "::add-mask::$AWS_WEB_IDENTITY_TOKEN"
echo "AWS_WEB_IDENTITY_TOKEN=$AWS_WEB_IDENTITY_TOKEN" >>"$GITHUB_ENV"

echo "::add-mask::$LAZY_API_KEY"
echo "::add-mask::$LAZY_API_URL"
{
  echo "LAZY_API_KEY=$LAZY_API_KEY"
  echo "LAZY_API_URL=$LAZY_API_URL"
} >>"$GITHUB_ENV"

echo "::add-mask::$GITHUB_APP_ID"
{
  echo "GITHUB_APP_ID=$GITHUB_APP_ID"
  echo "GITHUB_OWNER=$GITHUB_OWNER"
  echo "RUNNER_LABELS=$RUNNER_LABELS"
  echo "GITHUB_REPOSITORY=$GITHUB_REPOSITORY"
} >>"$GITHUB_ENV"

echo "::add-mask::$CONAN_KEY"
{
  echo "CONAN_KEY=$CONAN_KEY"
  echo "CONAN_LOGIN_USERNAME=$CONAN_LOGIN_USERNAME"
} >>"$GITHUB_ENV"
