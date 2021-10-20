all: solc install update
# Install proper solc version.
solc:; nix-env -f https://github.com/dapphub/dapptools/archive/master.tar.gz -iA solc-static-versions.solc_0_8_6
# Install npm dependencies.
install:; npm install
# Install dapp dependencies.
update:; dapp update

# Save a snapshot of gas usage.
snapshot:; DAPP_TEST_FUZZ_RUNS=1 dapp --snapshot