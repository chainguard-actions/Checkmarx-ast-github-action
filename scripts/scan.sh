#!/bin/bash

# ------------------------------------------------------
# Logic: Parse Params and Run Scan
# ------------------------------------------------------

# Parse global params (applied to all commands)
global_arr=()
if [ -n "${GLOBAL_PARAMS}" ]; then
  while IFS= read -r -d '' t; do global_arr+=("$t"); done \
    < <(printf '%s' "${GLOBAL_PARAMS}" | xargs printf '%s\0')
fi

# Parse scan-specific params
scan_arr=()
if [ -n "${SCAN_PARAMS}" ]; then
  while IFS= read -r -d '' t; do scan_arr+=("$t"); done \
    < <(printf '%s' "${SCAN_PARAMS}" | xargs printf '%s\0')
fi

# Backward compatibility: Support ADDITIONAL_PARAMS
if [ -n "${ADDITIONAL_PARAMS}" ] && [ -z "${SCAN_PARAMS}" ]; then
  echo "⚠️  ADDITIONAL_PARAMS is deprecated. Please use SCAN_PARAMS instead."
  scan_arr=()
  while IFS= read -r -d '' t; do scan_arr+=("$t"); done \
    < <(printf '%s' "${ADDITIONAL_PARAMS}" | xargs printf '%s\0')
fi

# Combine global + scan-specific params
combined_scan_params=("${global_arr[@]}" "${scan_arr[@]}")

# Execute Scan
/app/bin/cx scan create --project-name "${PROJECT_NAME}" -s "${SOURCE_DIR}" --branch "${BRANCH#refs/heads/}" --scan-info-format json --agent "Github Action" "${combined_scan_params[@]}" | tee -i "$output_file"
exitCode=${PIPESTATUS[0]}

# Extract Scan ID
scanId=(`grep -E '"(ID)":"((\\"|[^"])*)"' "$output_file" | cut -d',' -f1 | cut -d':' -f2 | tr -d '"'`)

# Output for GitHub Actions
echo "cxcli=$(cat "$output_file" | tr -d '\r\n')" >> $GITHUB_OUTPUT
