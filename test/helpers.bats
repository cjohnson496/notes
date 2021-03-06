#!/usr/bin/env bats

load test_helper


# `_get_title()` ##############################################################

@test "\`_get_title()\` detects and returns Markdown title formats." {
  {
    "${_NOTES}" init
    cat <<HEREDOC | "${_NOTES}" add "one.md"
# Title One
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "two.md"
line one
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "three.md"
# Title Three
line two
line three
line four
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "four.md"
---
summary: Example Summary
custom: variable
---
# Title Four
line six
line seven
line eight
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "five.md"
---
summary: Example Summary
title: Title Five
custom: variable
---
# Second Title Five
line seven
line eight
line nine
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "six.md"
---
summary: Example Summary
custom: variable
---
line five
line six
line seven
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "seven.md"
Title Seven
===========

line four
line five
line six
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "eight.md"
---
summary: Example Summary
custom: variable
---

  Title Eight
  ===========

line nine
line ten
line eleven
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "nine.md"
---
summary: Example Summary
custom: variable
---
Title Nine
===========

line nine
line ten
line eleven
HEREDOC
    cat <<HEREDOC | "${_NOTES}" add "ten.md"
# Title Ten #
line two
line three
line four
HEREDOC
    _files=($(ls "${_NOTEBOOK_PATH}/"))
  }

  run "${_NOTES}" list --titles --no-color
  [[ ${status} -eq 0 ]]

  printf "\${status}: %s\\n" "${status}"
  printf "\${output}: '%s'\\n" "${output}"
  printf "\${#lines[@]}: '%s'\\n" "${#lines[@]}"

  [[ "${lines[0]}" == "[10] Title Ten"     ]]
  [[ "${lines[1]}" == "[9]  Title Nine"    ]]
  [[ "${lines[2]}" == "[8]  Title Eight"   ]]
  [[ "${lines[3]}" == "[7]  Title Seven"   ]]
  [[ "${lines[4]}" == "[6]  six.md"        ]]
  [[ "${lines[5]}" == "[5]  Title Five"    ]]
  [[ "${lines[6]}" == "[4]  Title Four"    ]]
  [[ "${lines[7]}" == "[3]  Title Three"   ]]
  [[ "${lines[8]}" == "[2]  two.md"        ]]
  [[ "${lines[9]}" == "[1]  Title One"     ]]
}
