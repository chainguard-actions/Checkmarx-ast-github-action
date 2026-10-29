#!/bin/bash

# ------------------------------------------------------
# Logic: Parse Params and Run Scan
# ------------------------------------------------------

source /app/scripts/split_params.sh

# Parse global params (applied to all commands)
global_arr=()
if [ -n "${GLOBAL_PARAMS}" ]; then
  split_params "${GLOBAL_PARAMS}"
  global_arr=("${SPLIT_RESULT[@]}")
fi

# Parse scan-specific params
scan_arr=()
if [ -n "${SCAN_PARAMS}" ]; then
  split_params "${SCAN_PARAMS}"
  scan_arr=("${SPLIT_RESULT[@]}")
fi

# Backward compatibility: Support ADDITIONAL_PARAMS
if [ -n "${ADDITIONAL_PARAMS}" ] && [ -z "${SCAN_PARAMS}" ]; then
  echo "⚠️  ADDITIONAL_PARAMS is deprecated. Please use SCAN_PARAMS instead."
  split_params "${ADDITIONAL_PARAMS}"
  scan_arr=("${SPLIT_RESULT[@]}")
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
