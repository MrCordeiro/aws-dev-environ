{* An SSH configuration for Windows machines *}
add-content -path ~/.ssh/config -value @"

Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${indentityfile}
"@