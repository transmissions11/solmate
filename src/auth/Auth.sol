// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

/// @notice A generic interface for a contract which provides authorization data to an Auth instance.
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
}

/// @notice Provides a flexible and updatable auth pattern which is completely separate from application logic.
/// @author Modified from Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
abstract contract Auth {
    event OwnerUpdated(address indexed owner);

    event AuthorityUpdated(Authority indexed authority);

    address public owner;

    Authority public authority;

    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;

        emit OwnerUpdated(_owner);
        emit AuthorityUpdated(_authority);
    }

    function setOwner(address newOwner) public virtual requiresAuth {
        owner = newOwner;

        emit OwnerUpdated(owner);
    }

    function setAuthority(Authority newAuthority) public virtual requiresAuth {
        authority = newAuthority;

        emit AuthorityUpdated(authority);
    }

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool authorized) {
        assembly {
            let cachedAuthority := sload(authority.slot)

            if iszero(eq(cachedAuthority, 0x0000000000000000000000000000000000000000000000000000000000000000)) {
                // Get a pointer to some free memory.
                let freeMemoryPointer := mload(0x40)

                // Write the abi-encoded calldata to the slot in memory piece by piece:
                mstore(freeMemoryPointer, shl(224, 0xb7009613)) // Begin with the function selector.
                mstore(add(freeMemoryPointer, 4), and(user, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "user" argument.
                mstore(add(freeMemoryPointer, 36), and(address(), 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append our address.
                mstore(
                    add(freeMemoryPointer, 68),
                    and(functionSig, 0xffffffff00000000000000000000000000000000000000000000000000000000)
                ) // Finally append the "functionSig" argument. Must be masked as a bytes4 value.

                // Call the authority and store if it succeeded or not.
                // We use 100 because the calldata length is 4 + 32 * 3.
                let callStatus := staticcall(gas(), cachedAuthority, freeMemoryPointer, 100, 0, 0)

                // Get how many bytes the call returned.
                let returnDataSize := returndatasize()

                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // If the call reverted:
                if iszero(callStatus) {
                    // Revert with the same message .
                    revert(0, returnDataSize)
                }

                // Set authorized to whether it returned true.
                authorized := iszero(iszero(mload(0)))
            }

            if iszero(authorized) {
                authorized := eq(sload(owner.slot), and(user, 0xffffffffffffffffffffffffffffffffffffffff))
            }
        }
    }

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }
}
