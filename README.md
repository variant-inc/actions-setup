# Actions Setup
<!-- action-docs-description -->
## Description

Sets up all the required env variables to be used by others
<!-- action-docs-description -->

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

Sets environment variables that will be used by other Actions

## Usage

```yaml
    - name: Setup
      uses: variant-inc/actions-setup@v1
```
