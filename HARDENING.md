<!-- markdownlint-disable -->

# Hardening Report: Checkmarx--ast-github-action/2.3.36

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **Checkmarx--ast-github-action/2.3.36** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (b): Multiple shell scripts use `eval "arr=(${VAR})"` to parse user-controlled input parameters into arrays, without quoting or sanitizing the variable expansion. The env vars GLOBAL_PARAMS, SCAN_PARAMS, ADDITIONAL_PARAMS, UTILS_PARAMS, and RESULTS_PARAMS are all set directly from `inputs.*` in action.yml's env: block and are therefore attacker-controlled. An attacker can inject shell metacharacters (e.g., `); malicious_command; (`) to achieve arbitrary command execution inside the Docker container. Affected lines:
- scripts/scan.sh line 9: `eval "global_arr=(${GLOBAL_PARAMS})"`
- scripts/scan.sh line 16: `eval "scan_arr=(${SCAN_PARAMS})"`
- scripts/scan.sh line 24: `eval "scan_arr=(${ADDITIONAL_PARAMS})"`
- scripts/pr_decoration.sh line 9: `eval "utils_arr=(${UTILS_PARAMS})"`
- scripts/results.sh line 10: `eval "results_arr=(${RESULTS_PARAMS})"`

Locations:

- `scripts/scan.sh:9`
- `scripts/scan.sh:16`
- `scripts/scan.sh:24`
- `scripts/pr_decoration.sh:9`
- `scripts/results.sh:10`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Replaced all five instances of `eval "arr=(${VAR})"` with `read -ra arr <<< "${VAR}"` across three scripts:
- scripts/scan.sh lines 9, 16, 24: GLOBAL_PARAMS, SCAN_PARAMS, ADDITIONAL_PARAMS
- scripts/pr_decoration.sh line 9: UTILS_PARAMS
- scripts/results.sh line 10: RESULTS_PARAMS

The `read -ra` builtin performs safe word-splitting on IFS whitespace without invoking a shell interpreter, so attacker-controlled metacharacters (e.g., `); malicious_command; (`) are treated as literal data rather than executable shell code. This eliminates the arbitrary command execution vulnerability while preserving the intended behavior of splitting space-separated CLI flags into bash array elements.

