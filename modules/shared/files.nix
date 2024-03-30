{ ... }:

let
  # SSH stuff
  # TODO: The stuff below is kind of machine-specific, but this file is loaded by everything. Fix somehow.
  mbv-mba-agenix-ssh-key-pub =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFC5frMryx/RvGl8pWT0UsB6UcTHmqotmF4VV+vBnwZ5 mvilladsen@mbv-mba.local";
  mbv-mba-ssh-key-pub =
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw4EOQ09b7tm06Ulct4Lm44SEEqmx8DcvgRX+ZXofX/ mvilladsen@mbv-mba.local";
in {
  ".ssh/id_ed25519.pub" = { text = mbv-mba-ssh-key-pub; };
  ".ssh/id_agenix.pub" = { text = mbv-mba-agenix-ssh-key-pub; };
}
