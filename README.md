# solmate

**Modern**, **opinionated** and **gas optimized** building blocks for **smart contract development**.

## Contracts

```ml
auth
├─ Auth — "Flexible and updatable auth pattern"
├─ Trust — "Ultra minimal authorization logic"
├─ authorities
│  ├─ TrustAuthority — "Simple Authority which only authorizes trusted users"
│  ├─ RolesAuthority — "Role based Authority that supports up to 256 roles"
erc20
├─ ERC20 — "Modern and gas efficient ERC20 + EIP-2612 implementation"
├─ SafeERC20 — "Safe ERC20/ETH transfer lib that handles missing return values"
utils
├─ ReentrancyGuard — "Gas optimized reentrancy protection for smart contracts"
├─ FixedPointMath — "Arithmetic library with operations for fixed-point numbers"
```

## Acknowledgements

These contracts were inspired by or directly modified from many sources, primarily:

- [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts)
- **[Dappsys V2](https://github.com/dapp-org/dappsys-v2)**
- **[Dappsys](https://github.com/dapphub/dappsys)**
- [Uniswap](https://github.com/Uniswap/uniswap-lib)
