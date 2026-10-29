#!/bin/bash

# ------------------------------------------------------
# Helper: split a parameter string into the array SPLIT_RESULT without eval.
# Usage: split_params "<value>"; my_arr=("${SPLIT_RESULT[@]}")
# Honors single/double quotes like the shell would, but never evaluates
# command substitutions, variables, or any other shell syntax.
# ------------------------------------------------------
split_params() {
  local __value="$1"
  local __t
  SPLIT_RESULT=()
  if [ -n "$__value" ]; then
    if ! printf '%s' "$__value" | xargs -r true; then
      echo "Error: unmatched quote in parameters: $__value" >&2
      exit 1
    fi
    while IFS= read -r -d '' __t; do
      SPLIT_RESULT+=("$__t")
    done < <(printf '%s' "$__value" | xargs -r printf '%s\0')
  fi
}
