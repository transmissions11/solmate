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
/// @author Inspired by Dappsys (https://github.com/dapphub/ds-auth/blob/master/src/auth.sol)
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

            if iszero(eq(cachedAuthority, 0)) {
                // We'll use 4 + 32 * 3 bytes.
                let callDataLength := 100

                // Get a pointer to some free memory.
                let freeMemoryPointer := mload(0x40)

                // Update the free memory pointer for safety.
                mstore(0x40, add(freeMemoryPointer, callDataLength))

                // Write the abi-encoded calldata to memory piece by piece:
                mstore(freeMemoryPointer, shl(224, 0xb7009613)) // Properly shift and append the function selector for canCall(address,address,bytes4)
                mstore(add(freeMemoryPointer, 4), and(user, 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append the "user" argument.
                mstore(add(freeMemoryPointer, 36), and(address(), 0xffffffffffffffffffffffffffffffffffffffff)) // Mask and append our address.
                mstore(
                    add(freeMemoryPointer, 68),
                    and(functionSig, 0xffffffff00000000000000000000000000000000000000000000000000000000)
                ) // Finally mask and append the "functionSig" argument.

                // Call the authority and store if it succeeded or not.
                let callStatus := staticcall(gas(), cachedAuthority, freeMemoryPointer, callDataLength, 0, 0)

                // Get how many bytes the call returned.
                let returnDataSize := returndatasize()

                // If the call reverted:
                if iszero(callStatus) {
                    // Copy the revert message into memory.
                    returndatacopy(0, 0, returnDataSize)

                    // Revert with the same message.
                    revert(0, returnDataSize)
                }

                // If it returned more than 32 bytes:
                if iszero(eq(returnDataSize, 32)) {
                    // Revert without a message.
                    revert(0, 0)
                }

                // Copy the return data into memory.
                returndatacopy(0, 0, returnDataSize)

                // Set authorized to whether it returned true.
                authorized := iszero(iszero(mload(0)))
            }

            // If there was no authority or canCall returned false:
            if iszero(authorized) {
                // Set authorized to whether the user is the owner.
                authorized := eq(sload(owner.slot), user)
            }
        }
    }

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }
}
