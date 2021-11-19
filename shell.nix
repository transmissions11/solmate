let
  pkgs = import (builtins.fetchGit rec {
    name = "dapptools-${rev}";
    url = https://github.com/dapphub/dapptools;
    rev = "fb9476ded759da44c449eb391cc67bfb0df61112";
  }) {};

in
  pkgs.mkShell {
    src = null;
    name = "rari-capital-solmate";
    buildInputs = with pkgs; [
      pkgs.dapp
    ];
  }
