let
  pkgs = import (builtins.fetchGit rec {
    name = "dapptools-${rev}";
    url = https://github.com/dapphub/dapptools;
    rev = "a2b96cc2dbc28508c9fe699d6438bf6eccafc2ad";
  }) {};

in
  pkgs.mkShell {
    src = null;
    name = "rari-capital-solmate";
    buildInputs = with pkgs; [
      pkgs.dapp
    ];
  }