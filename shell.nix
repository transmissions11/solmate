let
  pkgs = import (builtins.fetchGit rec {
    name = "dapptools-${rev}";
    url = https://github.com/dapphub/dapptools;
    rev = "698a7060e0b001cd9bbcac00ae3625fbf7e4a48d";
  }) {};

in
  pkgs.mkShell {
    src = null;
    name = "rari-capital-solmate";
    buildInputs = with pkgs; [
      pkgs.dapp
    ];
  }