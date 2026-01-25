def remove_hash_prefix:
  sub("^(/nix/store/)?[a-z0-9]{32}-"; "");

def remove_version_suffix:
  sub("-[0-9]+.*$"; "");

def remove_file_ending:
  sub("\\.[a-z\\.]*$"; "");

def clean_deriv_name:
  remove_hash_prefix | remove_version_suffix | remove_file_ending | sub("\\.r[0-9]+$"; "");


def strip_hash:
  walk(
      if type == "object" then
        with_entries(.key |= clean_deriv_name)
      elif type == "string" then
        clean_deriv_name 
      else
        .
      end
    );

keys | strip_hash | unique
