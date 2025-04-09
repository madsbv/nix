{ hostname, mod, ... }:

{
  imports = [ (mod "system/nix-darwin") ];

  networking = {
    computerName = hostname;
    hostName = hostname;
    localHostName = hostname;
    knownNetworkServices = [
      "AX88179A"
      "Thunderbolt Bridge"
      "Wi-Fi"
      "iPhone USB"
    ];
    dns = [
      # Quad9 primary and secondary, including ipv6
      "9.9.9.9"
      "149.112.112.112"
      "2620:fe::fe"
      "2620:fe::9"
      # Cloudflare 1.1.1.1 malware blocking, primary and secondary, including ipv6
      "1.1.1.2"
      "1.0.0.2"
      "2606:4700:4700::1112"
      "2606:4700:4700::1002"
    ];
  };

  # Reimplementation of the launchd plist installed by tailscaled itself when invoked as `tailscaled install-system-daemonf (see https://github.com/tailscale/tailscale/wiki/Tailscaled-on-macOS)`
  # launchd.daemons = {
  #   tailscaled = {
  #     command = "${pkgs.tailscale}/bin/tailscaled";
  #     serviceConfig = {
  #       RunAtLoad = true;
  #       Label = "com.tailscale.tailscaled";
  #     };
  #   };
  # };
}
