#!/usr/bin/env bash
###############################################################################
# notes / scripts / get-bash-completion.bash
#
# https://github.com/xwmx/notes
###############################################################################

###############################################################################
# Strict Mode
#
# More Information:
#   https://github.com/xwmx/bash-boilerplate#bash-strict-mode
###############################################################################

set -o nounset
set -o errexit
trap 'echo "Aborting due to errexit on line $LINENO. Exit code: $?" >&2' ERR
set -o errtrace
set -o pipefail
IFS=$'\n\t'

###############################################################################

_get_bash_completion_path() {
  local _bash_completion_path=

  if [[ -n "${BASH_COMPLETION_COMPAT_DIR:-}" ]] &&
     [[ -w "${BASH_COMPLETION_COMPAT_DIR:-}" ]]
  then
    _bash_completion_path="${BASH_COMPLETION_COMPAT_DIR}"
  fi

  if [[ -z "${_bash_completion_path:-}" ]]
  then
    local _maybe_path
    _maybe_path="$(
      pkg-config --variable=completionsdir bash-completion 2>/dev/null || true
    )"

    if [[ -n "${_maybe_path:-}" ]] &&
       [[ -w "${_maybe_path:-}" ]]
    then
      _bash_completion_path="${_maybe_path}"
    fi
  fi

  if [[ -z "${_bash_completion_path:-}"       ]] &&
     [[ -d "/usr/local/etc/bash_completion.d" ]] &&
     [[ -w "/usr/local/etc/bash_completion.d" ]]
  then
    _bash_completion_path="/usr/local/etc/bash_completion.d"
  fi

  if [[ -z "${_bash_completion_path:-}" ]] &&
     [[ -d "/etc/bash_completion.d"     ]] &&
     [[ -w "/etc/bash_completion.d"     ]]
  then
    _bash_completion_path="/etc/bash_completion.d"
  fi

  printf "%s\\n" "${_bash_completion_path:-}"
} && _get_bash_completion_path