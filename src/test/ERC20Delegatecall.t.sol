// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.15;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockERC20} from "./utils/mocks/MockERC20.sol";

// Minimal proxy. The implementation address lives in the EIP-1967 slot,
// not in slot 0: the token name string occupies slot 0, and a slot-0
// implementation address would corrupt it under delegatecall.
contract ERC20DelegatecallProxy {
    bytes32 internal constant IMPLEMENTATION_SLOT =
        0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    constructor(address _implementation) {
        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            sstore(slot, _implementation)
        }
    }

    fallback() external payable {
        bytes32 slot = IMPLEMENTATION_SLOT;
        address impl;
        assembly {
            impl := sload(slot)
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }
}

contract ERC20DelegatecallTest is DSTestPlus {
    bytes32 constant PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");

    MockERC20 token;
    ERC20DelegatecallProxy proxy;

    function setUp() public {
        token = new MockERC20("Token", "TKN", 18);
        proxy = new ERC20DelegatecallProxy(address(token));
    }

    function testPermitViaDelegatecall() public {
        uint256 privateKey = 1;
        address owner = hevm.addr(privateKey);
        address spender = address(0xCAFE);
        uint256 value = 1e18;
        uint256 deadline = block.timestamp;

        // Under delegatecall the token reads name from the proxy storage,
        // which is empty, and address(this) is the proxy. This is the
        // separator the patched DOMAIN_SEPARATOR() recomputes.
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(MockERC20(address(proxy)).name())),
                keccak256("1"),
                block.chainid,
                address(proxy)
            )
        );

        (uint8 v, bytes32 r, bytes32 s) = hevm.sign(
            privateKey,
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    domainSeparator,
                    keccak256(abi.encode(PERMIT_TYPEHASH, owner, spender, value, 0, deadline))
                )
            )
        );

        MockERC20(address(proxy)).permit(owner, spender, value, deadline, v, r, s);

        assertEq(MockERC20(address(proxy)).allowance(owner, spender), value);
        assertEq(MockERC20(address(proxy)).nonces(owner), 1);
    }
}
