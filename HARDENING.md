<!-- markdownlint-disable -->

# Hardening Report: Checkmarx--ast-github-action/2.3.42

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **Checkmarx--ast-github-action/2.3.42** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unpinned-uses (severity: high)

Two `uses:` references in issue_automation.yml point to `@main` (a mutable branch ref) instead of a pinned 40-character commit SHA. This exposes the workflow to supply-chain attacks if the referenced repository is compromised.
- `Checkmarx/plugins-release-workflow/.github/workflows/jira_notify.yml@main`
- `Checkmarx/plugins-release-workflow/.github/workflows/jira_close.yml@main`

Locations:

- `.github/workflows/issue_automation.yml:13`
- `.github/workflows/issue_automation.yml:22`

### github-env-injection (severity: high)

In the `Tag` step of release.yml, the env var `INPUT_TAG` is set from `${{ github.event.inputs.tag }}` (a workflow_dispatch input, attacker-controllable). The run block writes `echo "NEXT_VERSION=${INPUT_TAG}" >> $GITHUB_ENV` without the required sanitization (`printf '%s' ... | tr -d '\n\r'`). A newline-containing tag value could inject arbitrary environment variables into subsequent steps.

Locations:

- `.github/workflows/release.yml:46`

### github-env-injection (severity: high)

In the `Get Version and SHA256 Manifest Digest` step of update-docker-image.yml, the env var `CLI_VERSION_INPUT` is set from `${{ github.event.inputs.cli_version }}` (a workflow_dispatch input, attacker-controllable). The script derives `RELEASE_TAG` from this value and writes `echo "RELEASE_TAG=$RELEASE_TAG" >> $GITHUB_ENV` without the required sanitization (`printf '%s' ... | tr -d '\n\r'`). A newline-containing version string could inject arbitrary environment variables into subsequent steps.

Locations:

- `.github/workflows/update-docker-image.yml:55`

## Iteration Notes

### Iteration 1

**Fixes applied:** unpinned-uses, github-env-injection

**Notes:**

Fixed 3 findings across 3 files:
1. issue_automation.yml: Pinned both `@main` workflow references (jira_notify.yml and jira_close.yml) to commit SHA e03847305df9c065dbba91c7878355723d1d38f8 with `# main` comment.
2. release.yml: Added sanitization of INPUT_TAG before writing to GITHUB_ENV: `safe_tag=$(printf '%s' "${INPUT_TAG}" | tr -d '\n\r')` then `echo "NEXT_VERSION=${safe_tag}" >> $GITHUB_ENV`.
3. update-docker-image.yml: Added sanitization of RELEASE_TAG, DIGEST, and CURRENT_TAG (all derived from the attacker-controllable CLI_VERSION_INPUT) before writing to GITHUB_ENV using `printf '%s' ... | tr -d '\n\r'`.

