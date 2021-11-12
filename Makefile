all: solc install update
# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_10
# Install npm dependencies.
install:; npm install
# Install dapp dependencies.
update:; dapp update
