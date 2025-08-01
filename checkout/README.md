# Actions Setup
<!-- action-docs-description -->
## Description

Checkout the repository and set up all the
required environment variables to be used by other actions.

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
      uses: variant-inc/actions-setup/checkout@v2
```
<!-- action-docs-description -->

<!-- markdownlint-disable line-length -->
<!-- action-docs-inputs -->

<!-- action-docs-inputs -->
<!-- markdownlint-enable line-length -->

<!-- action-docs-outputs -->

<!-- action-docs-outputs -->

<!-- action-docs-runs -->
## Runs

This action is a `composite` action.
<!-- action-docs-runs -->
