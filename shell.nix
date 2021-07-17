let
  pkgs = import (builtins.fetchGit rec {
    name = "dapptools-${rev}";
    url = https://github.com/dapphub/dapptools;
    rev = "5d2e0dd355893a2eaff11d5e08aa75fdbfba50b7";
  }) {};

in
  pkgs.mkShell {
    src = null;
    name = "rari-capital-dappsys";
    buildInputs = with pkgs; [
      pkgs.dapp
    ];
  }