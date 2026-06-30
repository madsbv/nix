{ config, lib, ... }: {
  options.local.userProfile = {
    username = lib.mkOption {
      type = lib.types.str;
      default = config.home.username;
    };
    fullName = lib.mkOption { type = lib.types.str; };
    email = lib.mkOption { type = lib.types.nullOr lib.types.str; };
  };
}
