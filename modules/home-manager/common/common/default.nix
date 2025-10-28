_:

{
  programs = {
    fd = {
      enable = true;
      hidden = true;
      ignores = [ ".git/" ];
    };
    git = {
      enable = true;
      lfs = {
        enable = true;
      };
    };
  };
}
