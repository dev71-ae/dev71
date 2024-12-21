let
  dev-atom = (import ./nix).dev { features = [ ]; };
in
dev-atom.shell
