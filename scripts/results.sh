#!/bin/bash

# ------------------------------------------------------
# Logic: Generate Results/Report
# ------------------------------------------------------

if [ -n "$scanId" ]; then
  # Parse results-specific params
  results_arr=()
  if [ -n "${RESULTS_PARAMS}" ]; then
    while IFS= read -r -d '' t; do results_arr+=("$t"); done \
      < <(printf '%s' "${RESULTS_PARAMS}" | xargs printf '%s\0')
  fi

  # Combine global + results-specific params
  combined_results_params=("${global_arr[@]}" "${results_arr[@]}")

  /app/bin/cx results show --scan-id "${scanId}" --report-format markdown "${combined_results_params[@]}"
  
  cat ./cx_result.md >$GITHUB_STEP_SUMMARY
  rm ./cx_result.md
  
  echo "cxScanID=$scanId" >> $GITHUB_OUTPUT
fi
