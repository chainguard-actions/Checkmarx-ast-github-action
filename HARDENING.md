<!-- markdownlint-disable -->

# Hardening Report: Checkmarx--ast-github-action/2.3.46

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **Checkmarx--ast-github-action/2.3.46** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): User-controlled input values are passed directly into `eval` without sanitization, allowing arbitrary shell command injection. The env vars GLOBAL_PARAMS, SCAN_PARAMS, ADDITIONAL_PARAMS, UTILS_PARAMS, and RESULTS_PARAMS are set from action inputs (inputs.global_params, inputs.scan_params, inputs.additional_params, inputs.utils_params, inputs.results_params) and then used in `eval "arr=(${VAR})"` constructs. An attacker can craft an input value such as `); malicious_command; arr=(` to escape the array assignment and execute arbitrary shell commands inside the Docker container.

Locations:

- `scripts/scan.sh:9`
- `scripts/scan.sh:15`
- `scripts/scan.sh:22`
- `scripts/pr_decoration.sh:8`
- `scripts/results.sh:9`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Replaced all 5 instances of `eval "arr=(${VAR})"` with safe xargs-based tokenization across three scripts:

1. scripts/scan.sh (lines 9, 15, 22): Replaced eval for GLOBAL_PARAMS, SCAN_PARAMS, and ADDITIONAL_PARAMS parsing.
2. scripts/pr_decoration.sh (line 8): Replaced eval for UTILS_PARAMS parsing.
3. scripts/results.sh (line 9): Replaced eval for RESULTS_PARAMS parsing.

The fix uses `while IFS= read -r -d '' t; do arr+=("$t"); done < <(printf '%s' "$VAR" | xargs printf '%s\0')` which:
- Tokenizes the input using xargs (respects single/double quotes and backslashes like a shell would)
- Does NOT evaluate shell metacharacters (`;`, `|`, `&&`, `$()`, backticks are passed as literal text)
- Uses NUL-delimited output to correctly handle tokens with spaces
- Guards with `if [ -n "$VAR" ]` to prevent xargs from emitting an empty token on empty input

The scripts use `#!/bin/bash` (sourced from entrypoint.sh which is bash), and the Docker base image (checkmarx/ast-cli) is not Alpine, so bash arrays and process substitution are available.

