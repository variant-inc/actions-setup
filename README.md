# Actions Setup

Sets environment variables that will be used by other Actions

## Environment Variables

Following environment variables are set by default in addition to `gitversion`

| Parameter             | Description             |
| --------------------- | ----------------------- |
| `SONAR_TOKEN`         | Sonar Token             |
| `SONAR_ORG`           | Sonar Organization Name |
| `AWS_ROLE_ARN`        | AWS Role ARN            |
| `OCTOPUS_CLI_SERVER`  | octopus cli Server      |
| `OCTOPUS_CLI_API_KEY` | octopus cli API key     |

## Output Variables

Following output variables are set by default in addition to `gitversion`

| Parameter       | Description                                                                          |
| --------------- | ------------------------------------------------------------------------------------ |
| `image_version` | Returns a semantic version that can used as a version for docker, helm, octopus, etc |

## Usage

```yaml
    - name: Setup
      uses: variant-inc/actions-setup@v1
```
