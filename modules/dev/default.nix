{ ... }:

{
  # Import all directories in this folder
  imports =
    with builtins;
    filter (p: readFileType p == "directory") (map (p: ./. + "/${p}") (attrNames (readDir ./.)));
}
