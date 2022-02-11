// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice A more efficient way to generate hashed typed data and a domain separator.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/EIP712Lib.sol)
/// @author Inspired by 0xProject (https://github.com/0xProject/0x-monorepo/blob/development/contracts/utils/contracts/src/LibEIP712.sol)
/// @author Inspired by OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/draft-EIP712.sol)
abstract contract EIP712 {
    bytes32 private _INITIAL_DOMAIN_SEPARATOR;

    uint256 private _INITIAL_CHAIN_ID;

    bytes32 private _HASHED_NAME;

    bytes32 private _HASHED_VERSION;

    bytes32 private constant _DOMAIN_TYPEHASH = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

    constructor(string memory name, string memory version) {
        // Hash variables using assembly for a more efficient computation
        assembly {
            sstore(_HASHED_NAME.slot, keccak256(add(name, 32), mload(name)))
            sstore(_HASHED_VERSION.slot, keccak256(add(version, 32), mload(version)))
            sstore(_INITIAL_CHAIN_ID.slot, chainid())
        }

        _INITIAL_DOMAIN_SEPARATOR = _buildDomainSeparator();
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == _INITIAL_CHAIN_ID ? _INITIAL_DOMAIN_SEPARATOR : _buildDomainSeparator();
    }

    function _buildDomainSeparator() private view returns (bytes32 result) {
        assembly {
            let ptr := mload(0x40)

            mstore(ptr, _DOMAIN_TYPEHASH) // Domain typehash
            mstore(add(ptr, 32), sload(_HASHED_NAME.slot)) // Hashed name
            mstore(add(ptr, 64), sload(_HASHED_VERSION.slot)) // Hashed version
            mstore(add(ptr, 96), chainid()) // Chain id
            mstore(add(ptr, 128), address()) // Verifying address

            result := keccak256(ptr, 160)
        }
    }

    function _hashTypedData(bytes32 digest) internal view returns (bytes32 result) {
        bytes32 domainSeparator = DOMAIN_SEPARATOR();
        assembly {
            let ptr := mload(0x40)

            mstore(ptr, 0x1901000000000000000000000000000000000000000000000000000000000000) // "\x19\z01" header
            mstore(add(ptr, 2), domainSeparator) // Domain separator
            mstore(add(ptr, 34), digest) // Hashed data

            result := keccak256(ptr, 66)
        }
    }
}
