# solmate

**Modern**, **opinionated** and **gas optimized** building blocks for **smart contract development**.

## Contracts

```ml
auth
├─ Auth — "Flexible and updatable auth pattern"
├─ Trust — "Ultra minimal authorization logic"
├─ authorities
│  ├─ RolesAuthority — "Role based Authority that supports up to 256 roles"
│  ├─ TrustAuthority — "Simple Authority which only authorizes trusted users"
erc20
├─ ERC20 — "Modern and gas efficient ERC20 + EIP-2612 implementation"
├─ SafeERC20 — "Safe ERC20/ETH transfer lib that handles missing return values"
utils
├─ SSTORE2 - "Library for cheaper reads and writes to persistent storage."
├─ CREATE3 — "Deploy to deterministic addresses without an initcode factor."
├─ ReentrancyGuard — "Gas optimized reentrancy protection for smart contracts"
├─ FixedPointMathLib — "Arithmetic library with operations for fixed-point numbers"
├─ Bytes32AddressLib — "Library for converting between addresses and bytes32 values"
```

## Installation

To install with **Hardhat** or **Truffle**:

```sh
npm install @rari-capital/solmate
```

To install with **DappTools**:

```sh
dapp install rari-capital/solmate
```

## Acknowledgements

These contracts were inspired by or directly modified from many sources, primarily:

- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)
- **[Dappsys V2](https://github.com/dapp-org/dappsys-v2)**
- **[Dappsys](https://github.com/dapphub/dappsys)**
- [Uniswap](https://github.com/Uniswap/uniswap-lib)
