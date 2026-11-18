$env.PROMPT_COMMAND = {||
  let current = ($env.PWD | str replace $nu.home-dir "~")
  let location = if $current == "~" {
    ""
  } else {
    $"(ansi '#737994')($current)(ansi reset)\n"
  }
  let devenv = if "DEVENV_ROOT" in $env { $"(ansi '#a6d189')devenv(ansi reset) " } else { "" }

  $"\n($location)(ansi '#8caaee')($env.USER)(ansi reset) ($devenv)(ansi '#f4b8e4')[λ](ansi reset) "
}

$env.PROMPT_COMMAND_RIGHT = {|| "" }
$env.PROMPT_INDICATOR = {|| "" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.PROMPT_MULTILINE_INDICATOR = {|| "..." }
