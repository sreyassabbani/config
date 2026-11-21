{
  # Touch ID for sudo, so `dr` run by an agent is approved with a fingerprint
  # instead of a typed or stored password. `reattach` keeps it working inside
  # terminal multiplexers such as Rex panes.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };
}
