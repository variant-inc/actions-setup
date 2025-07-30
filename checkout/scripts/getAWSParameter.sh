#!/bin/bash

# Set the parameter name (adjust this to your actual parameter)
PARAM_NAME=$1

# Retrieve the value from AWS SSM Parameter Store (adjust the region as needed)
PARAM_VALUE=$(aws ssm get-parameter --name "$PARAM_NAME" --query "Parameter.Value" --output text)

# Check if the parameter retrieval was successful
if ! PARAM_VALUE=$(aws ssm get-parameter --name "$PARAM_NAME" --query "Parameter.Value" --output text); then
	echo "Failed to retrieve parameter from AWS SSM Parameter Store."
	exit 1
fi

# Split the value by commas and store it in an array
IFS=',' read -ra PARAMS <<<"$PARAM_VALUE"

# Loop through each key-value pair in the array
for PARAM in "${PARAMS[@]}"; do
	# Split each element by '=' into key and value
	IFS='=' read -r KEY VALUE <<<"$PARAM"

	# Handle any potential spaces or special characters
	KEY=$(echo "$KEY" | xargs)     # Remove leading/trailing whitespace
	VALUE=$(echo "$VALUE" | xargs) # Remove leading/trailing whitespace

	# Optionally, export them as environment variables
	ENV_VAR_NAME=$(echo "$KEY" | tr '[:lower:]' '[:upper:]') # Convert key to uppercase for env var
	echo "$ENV_VAR_NAME"="$VALUE" >>"$GITHUB_ENV"
done
