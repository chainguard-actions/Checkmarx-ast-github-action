<!-- markdownlint-disable -->

# Hardening Report: Checkmarx--ast-github-action/2.3.37

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **Checkmarx--ast-github-action/2.3.37** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Multiple scripts use `eval` to parse user-controlled input parameters (GLOBAL_PARAMS, SCAN_PARAMS, ADDITIONAL_PARAMS, UTILS_PARAMS, RESULTS_PARAMS), which are all set directly from `inputs.*` in action.yml. The pattern `eval "arr=(${VAR})"` allows an attacker to inject arbitrary shell commands by supplying crafted values to these inputs. This violates sub-rule (b): shell expansion of untrusted data without proper quoting/sanitization, and more critically, `eval` with attacker-controlled content enables full command injection. Affected files: scripts/scan.sh (GLOBAL_PARAMS line ~10, SCAN_PARAMS line ~15, ADDITIONAL_PARAMS line ~21), scripts/pr_decoration.sh (UTILS_PARAMS line ~9), scripts/results.sh (RESULTS_PARAMS line ~9).

Locations:

- `scripts/scan.sh:10`
- `scripts/scan.sh:15`
- `scripts/scan.sh:21`
- `scripts/pr_decoration.sh:9`
- `scripts/results.sh:9`

### suspicious-run-content (severity: high)

eval-dynamic: Multiple run scripts use `eval "arr=(${VAR})"` where VAR is a workflow-controllable environment variable sourced from action inputs. This matches the eval-dynamic pattern — `eval` with shell variable expansion (`${}`) is used to dynamically construct and execute shell commands, which can be exploited to run arbitrary code. Specifically: `eval "global_arr=(${GLOBAL_PARAMS})"`, `eval "scan_arr=(${SCAN_PARAMS})"`, `eval "scan_arr=(${ADDITIONAL_PARAMS})"` in scripts/scan.sh; `eval "utils_arr=(${UTILS_PARAMS})"` in scripts/pr_decoration.sh; `eval "results_arr=(${RESULTS_PARAMS})"` in scripts/results.sh.

Locations:

- `scripts/scan.sh:10`
- `scripts/scan.sh:15`
- `scripts/scan.sh:21`
- `scripts/pr_decoration.sh:9`
- `scripts/results.sh:9`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, suspicious-run-content

**Notes:**

Replaced all 5 instances of `eval "arr=($VAR)"` with `read -ra arr <<< "$VAR"` across scripts/scan.sh (3 instances: GLOBAL_PARAMS, SCAN_PARAMS, ADDITIONAL_PARAMS), scripts/pr_decoration.sh (1 instance: UTILS_PARAMS), and scripts/results.sh (1 instance: RESULTS_PARAMS). The `read -ra` builtin safely splits the string on whitespace into array elements without interpreting shell metacharacters or executing embedded commands, eliminating the eval-based command injection vulnerability while preserving the intended functionality of passing user-supplied CLI flags to the cx binary.

