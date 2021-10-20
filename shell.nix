let
  pkgs = import (builtins.fetchGit rec {
    name = "dapptools-${rev}";
    url = https://github.com/dapphub/dapptools;
    rev = "d7a23096d8ae8391e740f6bdc4e8b9b703ca4764";
  }) {};

in
  pkgs.mkShell {
    src = null;
    name = "rari-capital-solmate";
    buildInputs = with pkgs; [
      pkgs.dapp
    ];
  }