let
  pkgs = import (builtins.fetchGit rec {
    name = "dapptools-${rev}";
    url = https://github.com/dapphub/dapptools;
    rev = "2b2c2a010f1a22a664cf17861c0d6812077f02b7";
  }) {};

in
  pkgs.mkShell {
    src = null;
    name = "rari-capital-solmate";
    buildInputs = with pkgs; [
      pkgs.dapp
    ];
  }