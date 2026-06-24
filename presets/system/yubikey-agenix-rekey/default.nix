{
  config,
  ...
}:
{
  config.local.agenix = {
    enable = true;
    ssh-clients.users = [ config.local.common.user ];
  };
}
