// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice A more efficient way to generate hashed typed data and a domain separator.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/utils/EIP712Lib.sol)
/// @author Inspired by 0xProject (https://github.com/0xProject/0x-monorepo/blob/development/contracts/utils/contracts/src/LibEIP712.sol)
/// @author Inspired by OpenZeppelin (https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/draft-EIP712.sol)
library EIP712 {
    bytes32 internal constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    function hashDomainSeparator(
        string memory name,
        string memory version,
        address verifyingContract
    ) internal view returns (bytes32 result) {
        bytes32 typehash = DOMAIN_TYPEHASH;

        assembly {
            let ptr := mload(0x40)

            mstore(ptr, typehash) // Domain typehash
            mstore(add(ptr, 32), keccak256(add(name, 32), mload(name))) // Hashed name
            mstore(add(ptr, 64), keccak256(add(version, 32), mload(version))) // Hashed version
            mstore(add(ptr, 96), chainid()) // Chain id
            mstore(add(ptr, 128), verifyingContract) // Verifying address

            result := keccak256(ptr, 160)
        }
    }

    function hashTypedData(bytes32 domainSeparator, bytes32 digest) internal pure returns (bytes32 result) {
        assembly {
            let ptr := mload(0x40)

            mstore(ptr, 0x1901000000000000000000000000000000000000000000000000000000000000) // "\x19\z01" header
            mstore(add(ptr, 2), domainSeparator) // Domain separator
            mstore(add(ptr, 34), digest) // Hashed data

            result := keccak256(ptr, 66)
        }
    }
}
