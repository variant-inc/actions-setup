#!/bin/bash

set -e

DEFAULT_SONAR_PROJECT_KEY=$(echo "$GITHUB_REPOSITORY" | tr / _)
echo "DEFAULT_SONAR_PROJECT_KEY=$DEFAULT_SONAR_PROJECT_KEY"

# Setting the project key and project name for sonar property values coming from dotnet app
SONAR_PROJECT_KEY_INPUT=$SONARCLOUD_PROJECT_KEY
SONAR_PROJECT_NAME_INPUT=$SONARCLOUD_PROJECT_NAME

if [ -f "sonar-project.properties" ]; then
	while IFS=" " read -r p || [ -n "$p" ]; do
		propKey=$(echo "$p" | cut -f1 -d'=')
		propVal=$(echo "$p" | cut -f2 -d'=')
		if [ "sonar.projectKey" == "$propKey" ]; then
			printf 'Found %s\n' "$propKey"
			SONAR_PROJECT_KEY_INPUT=$propVal
		elif [ "sonar.projectName" == "$propKey" ]; then
			printf 'Found %s\n' "$propKey"
			SONAR_PROJECT_NAME_INPUT=$propVal
		fi
	done <sonar-project.properties
fi

SONAR_PROJECT_KEY=${SONAR_PROJECT_KEY_INPUT:=$DEFAULT_SONAR_PROJECT_KEY}
SONAR_PROJECT_NAME=${SONAR_PROJECT_NAME_INPUT:=$SONAR_PROJECT_KEY}
{
	echo "SONAR_PROJECT_KEY=$SONAR_PROJECT_KEY"
	echo "SONAR_PROJECT_NAME=$SONAR_PROJECT_NAME"
} >>"$GITHUB_ENV"
