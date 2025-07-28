// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/// @notice Yul-based gas-optimized ECDSA signature recovery
library ECDSA {
    function recover(bytes32 hash, bytes memory signature) internal view returns (address) {
        if (signature.length != 65) return address(0);

        assembly {
            let ptr := mload(0x40)

            let r := mload(add(signature, 0x20))
            let s := mload(add(signature, 0x40))
            let v := byte(0, mload(add(signature, 0x60)))

            // Reject malleable signatures by ensuring s <= secp256k1n / 2
            if gt(s, div(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141, 2)) {
                mstore(ptr, 0)
                return(ptr, 0x20)
            }

            // Pack for ecrecover
            mstore(ptr, r)
            mstore(add(ptr, 0x20), s)
            mstore(add(ptr, 0x40), hash)
            mstore(add(ptr, 0x60), v)

            let success := staticcall(gas(), 0x01, add(ptr, 0x40), 0x80, ptr, 0x20)

            if iszero(success) {
                mstore(ptr, 0)
            }

            return(ptr, 0x20)
        }
    }

    function recover(bytes32 hash, bytes32 r, bytes32 s, uint8 v) internal view returns (address) {
        if (v < 27) v += 27;
        bytes memory signature = abi.encodePacked(r, s, v);
        return recover(hash, signature);
    }
}
