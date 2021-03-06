#!/usr/bin/env bats

load test_helper

# #############################################################################

@test "\`settings\` with no arguments prints help." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${lines[0]}" =~ "Usage:" ]]
}

# `colors` ####################################################################

@test "\`settings colors\` prints colors." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings colors

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ '   0' ]]
}

# `edit` ######################################################################

@test "\`settings edit\` edits .notesrc." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings edit

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "$(cat "${NOTESRC_PATH}")" =~ 'mock_editor' ]]
}

# `get` #######################################################################

@test "\`settings get\` with no argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings get

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Usage' ]]
}

@test "\`settings get\` with invalid argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings get EXAMPLE

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ Setting\ not\ found\:\ \'EXAMPLE\' ]]
}

@test "\`settings get\` with argument exits and prints." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings get NOTES_DIR

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ ${NOTES_DIR} ]]
}


# `set` #######################################################################

@test "\`settings set\` with no argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Usage' ]]
}


@test "\`settings set\` with invalid argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set EXAMPLE example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ Setting\ not\ found\:\ \'EXAMPLE\' ]]
}

@test "\`settings set\` with one argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set EDITOR

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Usage' ]]
}

@test "\`settings set\` with argument exits and sets." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set EDITOR example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ EDITOR\ set\ to\ \'example\' ]]
  [[ "$(cat "${NOTESRC_PATH}")" =~ 'EDITOR=example' ]]
}

# `set NOTES_AUTO_SYNC` #######################################################


@test "\`settings set NOTES_AUTO_SYNC\` with valid argument sets and exits." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set NOTES_AUTO_SYNC 0

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NOTES_AUTO_SYNC\ set\ to\ \'0\' ]]
  [[ "$("${_NOTES}" settings get NOTES_AUTO_SYNC)" == '0' ]]
}

@test "\`settings set NOTES_AUTO_SYNC\` with invalid argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set NOTES_AUTO_SYNC '0'
  [[ "${output}" =~ NOTES_AUTO_SYNC\ set\ to\ \'0\' ]]
  run "${_NOTES}" settings set NOTES_AUTO_SYNC example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" == "NOTES_AUTO_SYNC must be either '0' or '1'." ]]
  [[ "$("${_NOTES}" settings get NOTES_AUTO_SYNC)" == '0' ]]
}

# `set NOTES_ENCRYPTION_TOOL` #################################################

@test "\`settings set NOTES_ENCRYPTION_TOOL\` with valid argument sets and exits." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set NOTES_ENCRYPTION_TOOL gpg

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NOTES_ENCRYPTION_TOOL\ set\ to\ \'gpg\' ]]
  [[ "$("${_NOTES}" settings get NOTES_ENCRYPTION_TOOL)" == 'gpg' ]]
}

@test "\`settings set NOTES_ENCRYPTION_TOOL\` with invalid argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set NOTES_ENCRYPTION_TOOL 'gpg'
  [[ "${output}" =~ NOTES_ENCRYPTION_TOOL\ set\ to\ \'gpg\' ]]
  run "${_NOTES}" settings set NOTES_ENCRYPTION_TOOL example

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" == "NOTES_ENCRYPTION_TOOL must be either 'openssl' or 'gpg'." ]]
  [[ "$("${_NOTES}" settings get NOTES_ENCRYPTION_TOOL)" == 'gpg' ]]
}

# `set NOTES_HIGHLIGHT_COLOR` #################################################

@test "\`settings set NOTES_HIGHLIGHT_COLOR\` with valid argument sets and exits." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set NOTES_HIGHLIGHT_COLOR 123

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 0 ]]
  [[ "${output}" =~ NOTES_HIGHLIGHT_COLOR\ set\ to\ \'123\' ]]
  [[ "$("${_NOTES}" settings get NOTES_HIGHLIGHT_COLOR)" == '123' ]]
}

@test "\`settings set NOTES_HIGHLIGHT_COLOR\` with invalid argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings set NOTES_HIGHLIGHT_COLOR 123
  [[ "${output}" =~ NOTES_HIGHLIGHT_COLOR\ set\ to\ \'123\' ]]
  run "${_NOTES}" settings set NOTES_HIGHLIGHT_COLOR 257

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" == 'NOTES_HIGHLIGHT_COLOR must be number between 0 and 255.' ]]
  [[ "$("${_NOTES}" settings get NOTES_HIGHLIGHT_COLOR)" == '123' ]]
}

# `unset` #####################################################################

@test "\`settings unset\` with no argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings unset

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ 'Usage' ]]
}

@test "\`settings unset\` with invalid argument exits with error." {
  {
    "${_NOTES}" init
  }

  run "${_NOTES}" settings unset EXAMPLE

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  [[ ${status} -eq 1 ]]
  [[ "${output}" =~ Setting\ not\ found\:\ \'EXAMPLE\' ]]
}

@test "\`settings unset\` with argument unset, prints, and exits." {
  {
    "${_NOTES}" init
    run "${_NOTES}" settings set EDITOR sample
    [[ "$("${_NOTES}" settings get EDITOR)" == 'sample' ]]
    [[ "$(cat "${NOTESRC_PATH}")" =~ 'EDITOR=sample' ]]
  }

  run "${_NOTES}" settings unset EDITOR

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf ".notesrc:\\n'%s'\\n" "$(cat "${NOTESRC_PATH}")"
  [[ ${status} -eq 0 ]]
  [[ ! "$(cat "${NOTESRC_PATH}")" =~ 'EDITOR=sample' ]]
  [[ "${output}" =~ EDITOR\ restored\ to\ the\ default ]]
  [[ ! "${output}" =~ sample ]]
}
