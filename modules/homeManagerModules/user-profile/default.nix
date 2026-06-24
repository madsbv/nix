{ config, lib, ... }: {
  options.local.userProfile = {
    username = lib.mkOption { type = lib.types.str; };
    fullName = lib.mkOption { type = lib.types.str; };
    email    = lib.mkOption { type = lib.types.nullOr lib.types.str; };
  };
  config.local.userProfile.username = lib.mkDefault config.home.username;
}
