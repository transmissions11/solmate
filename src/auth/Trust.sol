// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Ultra minimal authorization logic for smart contracts.
/// @author Inspired by DappHub (https://github.com/dapp-org/dappsys-v2/blob/main/src/auth.sol)
contract Trust {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event UserTrustUpdated(address indexed user, bool trusted);

    /*///////////////////////////////////////////////////////////////
                              TRUST STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bool) public isTrusted;

    constructor() {
        isTrusted[msg.sender] = true;

        emit UserTrustUpdated(msg.sender, true);
    }

    /*///////////////////////////////////////////////////////////////
                         TRUST MODIFIER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function setIsTrusted(address user, bool trusted) public requiresTrust {
        isTrusted[user] = trusted;

        emit UserTrustUpdated(user, trusted);
    }

    /*///////////////////////////////////////////////////////////////
                              TRUST LOGIC
    //////////////////////////////////////////////////////////////*/

    modifier requiresTrust() {
        require(isTrusted[msg.sender], "UNTRUSTED");

        _;
    }
}
