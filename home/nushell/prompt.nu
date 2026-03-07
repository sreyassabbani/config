$env.PROMPT_COMMAND = {||
  let current = ($env.PWD | str replace $nu.home-path "~")
  let location = if $current == "~" {
    ""
  } else {
    $"(ansi '#737994')($current)(ansi reset)\n"
  }

  $"\n($location)(ansi '#8caaee')($env.USER)(ansi reset) (ansi '#f4b8e4')[λ](ansi reset) "
}

$env.PROMPT_COMMAND_RIGHT = {|| "" }
$env.PROMPT_INDICATOR = {|| "" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.PROMPT_MULTILINE_INDICATOR = {|| "..." }
