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

    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority cachedAuthority = authority;

        if (address(cachedAuthority) != address(0)) {
            try cachedAuthority.canCall(user, address(this), functionSig) returns (bool canCall) {
                if (canCall) return true;
            } catch {}
        }

        return user == owner;
    }

    modifier requiresAuth() {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");

        _;
    }
}
