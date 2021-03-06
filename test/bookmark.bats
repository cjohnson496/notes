#!/usr/bin/env bats

load test_helper

_BOOKMARK_URL="file://${BATS_TEST_DIRNAME}/fixtures/example.com.html"

# no argument #################################################################

@test "\`bookmark\` with no argument exits with 1." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1
  [[ ${status} -eq 1 ]]

  # Does not create note file
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]

  # Does not create git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Add') ]]

  # Prints help information
  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~ notes\ bookmark ]]
}

# <url> argument ##############################################################

@test "\`bookmark\` with invalid <url> argument exits with 1." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark 'invalid url'
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Exits with status 1
  [[ ${status} -eq 1 ]]

  # Does not create note file
  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]

  # Does not create git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ ! $(git log | grep '\[NOTES\] Add') ]]

  # Prints help information
  [[ "${lines[0]}" == "Unable to download page at 'invalid url'" ]]
}

@test "\`bookmark\` with valid <url> argument creates new note without errors." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note with bookmark filename
  [[ "${_filename}}" =~ [A-Za-z0-9]+.bookmark.md ]]

  # Creates new note file with content
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.com.html>

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.

[More information\...](https://www.iana.org/domains/example)"
  printf "cat file: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${_NOTEBOOK_PATH}"/*) ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+.bookmark.md ]]
}

# --comment option ############################################################

@test "\`bookmark\` with --comment option creates new note with comment." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --comment "New comment."
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.com.html>

## Comment

New comment.

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.

[More information\...](https://www.iana.org/domains/example)"
  printf "cat file: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${_NOTEBOOK_PATH}"/*) ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+.bookmark.md ]]
}

# --skip-content option #######################################################

@test "\`bookmark\` with --skip-content option creates new note with no page content." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --skip-content
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.com.html>"
  printf "cat file: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${_NOTEBOOK_PATH}"/*) ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+.bookmark.md ]]
}

# --tags option ###############################################################

@test "\`bookmark\` with --tags option creates new note with tags." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --tags tag1,tag2
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.com.html>

## Tags

#tag1 #tag2

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.

[More information\...](https://www.iana.org/domains/example)"
  printf "cat file: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${_NOTEBOOK_PATH}"/*) ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+.bookmark.md ]]
}

@test "\`bookmark\` with --tags option and hashtags creates new note with tags." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --tags '#tag1','#tag2' -c 'Example comment.'
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# Example Domain

<file://${BATS_TEST_DIRNAME}/fixtures/example.com.html>

## Comment

Example comment.

## Tags

#tag1 #tag2

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.

[More information\...](https://www.iana.org/domains/example)"
  printf "cat file: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# Example Domain' "${_NOTEBOOK_PATH}"/*) ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+.bookmark.md ]]
}

# --title option ##############################################################

@test "\`bookmark\` with --title option creates new note with title." {
  {
    run "${_NOTES}" init
  }

  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --title "New Title"
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Creates new note file with content
  _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  [[ "${#_files[@]}" -eq 1 ]]
  _bookmark_content="\
# New Title

<file://${BATS_TEST_DIRNAME}/fixtures/example.com.html>

## Content

Example Domain
==============

This domain is for use in illustrative examples in documents. You may use this domain in literature without prior coordination or asking for permission.

[More information\...](https://www.iana.org/domains/example)"
  printf "cat file: '%s'\\n" "$(cat "${_NOTEBOOK_PATH}/${_filename}")"
  printf "\${_bookmark_content}: '%s'\\n" "${_bookmark_content}"
  [[ "$(cat "${_NOTEBOOK_PATH}/${_filename}")" == "${_bookmark_content}" ]]
  [[ $(grep '# New Title' "${_NOTEBOOK_PATH}"/*) ]]

  # Creates git commit
  cd "${_NOTEBOOK_PATH}" || return 1
  while [[ -n "$(git status --porcelain)" ]]
  do
    sleep 1
  done
  [[ $(git log | grep '\[NOTES\] Add') ]]

  # Adds to index
  [[ -e "${_NOTEBOOK_PATH}/.index" ]]
  [[ "$(ls "${_NOTEBOOK_PATH}")" == "$(cat "${_NOTEBOOK_PATH}/.index")" ]]

  # Prints output
  [[ "${output}" =~ Added\ \[[0-9]+\]\ [A-Za-z0-9]+.bookmark.md ]]
}

# --encrypt option ############################################################

@test "\`bookmark --encrypt\` with content argument creates a new .enc bookmark." {
  run "${_NOTES}" init
  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --encrypt --password=example

  [[ ${status} -eq 0 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 1 ]]
  [[ "${_files[0]}" =~ enc$ ]]
  [[ "$(file "${_NOTEBOOK_PATH}/${_files[0]}" | cut -d: -f2)" =~ encrypted|openssl ]]
}

@test "\`bookmark --encrypt --password\` without argument exits with 1." {
  run "${_NOTES}" init
  run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --encrypt --password

  [[ ${status} -eq 1 ]]

  _files=($(ls "${_NOTEBOOK_PATH}/"))
  [[ "${#_files[@]}" -eq 0 ]]
}

# `bookmark url` ##############################################################

@test "\`bookmark url\` with invalid note prints error." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" bookmark "${_BOOKMARK_URL}"
  }

  run "${_NOTES}" bookmark url 99
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 1 ]]

  # Prints output
  [[ "${output}" =~ Note\ not\ found ]]
}

@test "\`bookmark url\` prints note url." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" bookmark "${_BOOKMARK_URL}"
  }

  run "${_NOTES}" bookmark url 1
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Prints output
  [[ "${output}" == "${_BOOKMARK_URL}" ]]
}

@test "\`bookmark url\` with multiple URLs prints first url in <>." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" add example.bookmark.md \
      --content "\
https://example.com
<${_BOOKMARK_URL}>
<https://example.com>"
  }

  run "${_NOTES}" bookmark url 1
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Prints output
  [[ "${output}" == "${_BOOKMARK_URL}" ]]
}

# encrypted ###################################################################

@test "\`bookmark url\` with encrypted bookmark should print without errors." {
  {
    run "${_NOTES}" init
    run "${_NOTES}" bookmark "${_BOOKMARK_URL}" --encrypt --password=example
    _files=($(ls "${_NOTEBOOK_PATH}/")) && _filename="${_files[0]}"
  }

  run "${_NOTES}" bookmark url 1 --password=example
  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  # Returns status 0
  [[ ${status} -eq 0 ]]

  # Prints output
  [[ "${output}" == "${_BOOKMARK_URL}" ]]
}

# help ########################################################################

@test "\`help bookmark\` exits with status 0 and prints." {
  run "${_NOTES}" help bookmark

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"

  [[ ${status} -eq 0 ]]

  [[ "${lines[0]}" == "Usage:" ]]
  [[ "${lines[1]}" =~  notes\ bookmark ]]
}
