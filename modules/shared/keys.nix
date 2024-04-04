{ flake-root, nodes, user, hostname, config, lib, pkgs, ... }:

let
  cfg = config.keys;
  pubHostKeyPath = flake-root + "/pubkeys/ssh";
  getHostKey = host: pubHostKeyPath + "/ssh_host_ed25519_key.pub.${host}";
in {
  cfg.serverPubHostKeys = map getHostKey nodes.servers;
  cfg.clientPubHostKeys = map getHostKey nodes.clients;
}
