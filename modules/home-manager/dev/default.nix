{
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev;

  # Get all directory names in the current folder
  allDevModuleNames =
    with builtins;
    filter (p: readFileType (./. + "/${p}") == "directory") (attrNames (readDir ./.));
in
{
  # Import all directories in this folder
  imports =
    with builtins;
    filter (p: readFileType p == "directory") (map (p: ./. + "/${p}") (attrNames (readDir ./.)));

  options.local.dev = {
    enable = lib.mkEnableOption "Development tools";
    modules = lib.mkOption {
      type = with lib.types; listOf str;
      default = allDevModuleNames;
      description = "List of dev module names to enable";
      example = [
        "python"
        "rust"
        "nix"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable all modules specified in cfg.modules
    local.dev = lib.mkMerge (
      map (moduleName: {
        ${moduleName}.enable = lib.mkIf (builtins.elem moduleName cfg.modules) true;
      }) allDevModuleNames
    );
  };
}
