# Contributing

## AWS Secrets

The secret used in setup should have the following variables

1. SONAR_TOKEN
2. SONAR_ORGS --> Map of GitHub orgs to Sonar orgs
3. OCTOPUS_CLI_SERVER
4. OCTOPUS_CLI_API_KEY
5. LAZY_API_KEY
6. LAZY_API_URL

## AWS Role

- The role provided should be able to run in the different orgs in the enterprise.
- The role needs access to secret with variables above &
  read access to `trivy-ops` s3 bucket.

## Versioning

Merges to master will create a MajorMinorPatch tag, update MajorMinor & Major tags

To create a new Major tag or MajorMinor tag, then manually create and push
the tag the first time.
