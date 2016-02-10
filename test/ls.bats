#!/usr/bin/env bats

load test_helper


_setup_ls() {
  "$_NOTES" init
    cat <<HEREDOC | "$_NOTES" add
# one
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "$_NOTES" add
# two
line two
line three
line four
HEREDOC
    sleep 1
    cat <<HEREDOC | "$_NOTES" add
# three
line two
line three
line four
HEREDOC
}

# `notes ls` ################################################################

@test "\`ls\` exits with 0 and lists files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${lines[0]}" "three"

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two   ]]
  [[ "${lines[2]}" =~ one   ]]
}

# `notes ls -e [<excerpt length>]` ############################################

@test "\`ls -e <excerpt length>\` exits with 0 and displays excerpts." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls -e 5
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  printf "\${#lines[@]}: '%s'\n" "${#lines[@]}"

  [[ "${#lines[@]}" -eq 18 ]]
}

# `notes ls <number>` #########################################################

@test "\`ls 0\` exits with 1 and lists 0 files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls 0
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 0 ]]
}

@test "\`ls 1\` exits with 0 and lists 1 file." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls 1
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 2 ]]

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" == "2 omitted. 3 total." ]]
}

@test "\`ls 2\` exits with 0 and lists 2 files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls 2
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two   ]]
  [[ "${lines[2]}" == "1 omitted. 3 total." ]]
}

@test "\`ls 3\` exits with 0 and lists 3 files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls 3
  [[ $status -eq 0 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 3 ]]

  [[ "${lines[0]}" =~ three ]]
  [[ "${lines[1]}" =~ two   ]]
  [[ "${lines[2]}" =~ one   ]]
}

@test "\`ls <[[:alpha:]]>\` exits with 1 and lists 0 files." {
  {
    _setup_ls
    _files=($(ls "${NOTES_DATA_DIR}/"))
  }

  run "$_NOTES" ls x
  [[ $status -eq 1 ]]

  printf "\$status: %s\n" "$status"
  printf "\$output: '%s'\n" "$output"
  _compare "${lines[0]}" "three"

  [[ "${#lines[@]}" -eq 0 ]]
}