// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.7.0;

/// @notice Ultra minimal authorization logic for smart contracts.
/// @author Inspired by Dappsys V2 (https://github.com/dapp-org/dappsys-v2/blob/main/src/auth.sol)
abstract contract Trust {
    event UserTrustUpdated(address indexed user, bool trusted);

    mapping(address => bool) public isTrusted;

    constructor(address initialUser) {
        isTrusted[initialUser] = true;

        emit UserTrustUpdated(initialUser, true);
    }

    function setIsTrusted(address user, bool trusted) public virtual requiresTrust {
        isTrusted[user] = trusted;

        emit UserTrustUpdated(user, trusted);
    }

    modifier requiresTrust() {
        require(isTrusted[msg.sender], "UNTRUSTED");

        _;
    }
}
