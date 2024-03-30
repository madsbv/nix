{ pkgs, ... }:

let
  xdg_dataHome = "/Users/mvilladsen/.local/share";
in {
  # Raycast script so that "Run Emacs" is available and uses Emacs daemon
  "${xdg_dataHome}/bin/emacsclient" = {
    executable = true;
    text = ''
      #!/bin/zsh
      #
      # Required parameters:
      # @raycast.schemaVersion 1
      # @raycast.title Run Emacs
      # @raycast.mode silent
      #
      # Optional parameters:
      # @raycast.packageName Emacs
      # @raycast.icon ${xdg_dataHome}/img/icons/Emacs.icns
      # @raycast.iconDark ${xdg_dataHome}/img/icons/Emacs.icns

      if [[ $1 = "-t" ]]; then
        # Terminal mode
        ${pkgs.my-emacs-mac}/bin/emacsclient -t $@
      else
        # GUI mode
        ${pkgs.my-emacs-mac}/bin/emacsclient -c -n $@
      fi
    '';
  };
}
