{ config, lib, pkgs, ... }:
### Defines and sets minimal permissions for a "builder" user which other machines can SSH into via tailscale ssh (controlled by tailscale ACL). Should be written so it can be imported as-is into either a nix-darwin or nixos configuration.
#

# QUESTION: Can we do something like `global-list = [ hostname ]` in this file and then, on nix evaluation, rely on the merging behaviour to populate global-list with all hostnames that have builder users? It's unclear to me how this works if only one system is evaluated. TEST!
{
  users.users.builder = { isSystemUser = true; };
}
