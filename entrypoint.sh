#!/bin/bash

set -e

sudo chown -R github:github "$GITHUB_WORKSPACE"/*
sudo git clean -fdx

## Reference: https://github.com/GitTools/actions/
curl -sL https://raw.githubusercontent.com/GitTools/actions/main/dist/github/gitversion/execute/bundle.js -o gitversion-execute.js
node gitversion-execute.js
rm gitversion-execute.js

echo "::add-mask::$SONAR_TOKEN"
echo "::add-mask::$OCTOPUS_CLI_API_KEY"
{
  echo "SONAR_TOKEN=$SONAR_TOKEN"
  echo "SONAR_ORG=$SONAR_ORG"
  echo "OCTOPUS_CLI_SERVER=$OCTOPUS_CLI_SERVER"
  echo "OCTOPUS_CLI_API_KEY=$OCTOPUS_CLI_API_KEY"
} >>"$GITHUB_ENV"

echo "AWS_ROLE_ARN=$AWS_ROLE_ARN" >>"$GITHUB_ENV"
AWS_WEB_IDENTITY_TOKEN="$(cat "$AWS_WEB_IDENTITY_TOKEN_FILE")"
echo "::add-mask::$AWS_WEB_IDENTITY_TOKEN"
echo "AWS_WEB_IDENTITY_TOKEN=$AWS_WEB_IDENTITY_TOKEN" >>"$GITHUB_ENV"
