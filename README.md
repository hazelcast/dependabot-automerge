# Dependabot Automerge

## How to enable automerging in your repository
 
- Request for it on [`#dev-infra-support` Slack channel](https://hazelcast.slack.com/archives/C07066ELRRD)

## How to configure automerging in your repository

By default, the workflow will try to automerge PRs updating dependencies configured in [default-dependabot-automerge-whitelist.conf](https://github.com/hazelcast/dependabot-automerge/blob/master/.github/workflows/default-dependabot-automerge-whitelist.conf).

You can override the settings for your repository by creating a `.github/workflows/dependabot-automerge-whitelist.conf` file on the default branch (`master`/`main`) of your repository. The file will be used instead of the default configuration.

### Configuration file format

Each line describes a dependency.

- The first column (mandatory) is a pattern that the dependency name from a PR has to contain. 
- The second column (optional) contains maximum update type that will be automerged for a matching dependency. It has to be one of `major`, `minor` or `patch`. When the second column is omitted, it defaults to `patch` which means that only patch updates will be automerged (if they pass other of your PR checks). 

## How to enable automerging for a requested repository (admins only)

- Make sure the repository has access to the following secrets: `GH_PAT_FOR_AUTOMERGING`, `SLACK_WEBHOOK_FOR_AUTOMERGING`
- Enable `Allow auto-merge` in the settings of the repository
- Add the repository to target repositories in the [`dependabot-automerge` ruleset](https://github.com/organizations/hazelcast/settings/rules/286995)
- (Optional) Add `devOpsHazelcast` user to the `.github/CODEOWNERS` file on the default branch (`master`/`main`). Otherwise, automerging will wait for approval from a code owner.

## How to configure global workflow for automerging (admins only)

- [Add the new branch ruleset](https://github.com/organizations/hazelcast/settings/rules)
- Enforcement status to `Evaluate` to make the workflow non-required for the PRs
- Select target repositories you want to have dependabot automerging functionality
- Select default branch (`Include default branch`) as a target branch
- Uncheck everything in `Branch protections` and select `Require workflows to pass before merging` only
- Add the workflow: choose `dependabot-automerge` repository first, then `.github/workflows/dependabot-automerge.yaml` workflow from the default branch (`master`/`main`)

