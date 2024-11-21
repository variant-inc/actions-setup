# Actions Setup
<!-- action-docs-description -->
## Description

Sets up all the required env variables to be used by others

<!-- markdownlint-disable line-length -->
- **Secret Environment Variables**: It retrieves secret values stored in AWS Secrets Manager from the ARN `arn:aws:secretsmanager:us-east-2:108141096600:secret:actions-secret-v2` and sets them as secret environment variables.

- **Non-Secret Environment Variables**: It retrieves non-secret variables from the AWS SSM Parameter Store using the ARN `arn:aws:ssm:us-east-2:108141096600:parameter/actions-envs` and sets them as regular environment variables.

This allows the application to securely access both sensitive and non-sensitive configuration values without hardcoding them.
<!-- markdownlint-enable line-length -->

## Permissions

Add the following permissions to the job

```yaml
permissions:
  id-token: write
  contents: read
```

## Usage

```yaml
    - name: Setup
      uses: variant-inc/actions-setup@v2
```
<!-- action-docs-description -->

<!-- markdownlint-disable line-length -->
<!-- action-docs-inputs -->

<!-- action-docs-inputs -->
<!-- markdownlint-enable line-length -->

<!-- action-docs-outputs -->
## Outputs

| parameter | description |
| --- | --- |
| image_version | Returns a semantic version that can used as a version for docker, helm, octopus, etc |
<!-- action-docs-outputs -->

<!-- action-docs-runs -->
## Runs

This action is a `composite` action.
<!-- action-docs-runs -->
