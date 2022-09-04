cat << EOF >> ~/.ssh/configuration

Host ${hostname}
  HostName ${hostname}
  User ${user}
  IdentityFile ${indentityfile}
EOF