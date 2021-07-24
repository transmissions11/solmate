// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Ultra minimal authorization for smart contracts.
/// @author Modified from DappHub (https://github.com/dapp-org/dappsys-v2/blob/main/src/auth.sol)
contract Trust {
    /*///////////////////////////////////////////////////////////////
                                  EVENTS
    //////////////////////////////////////////////////////////////*/

    event UserTrusted(address indexed usr);

    event UserDistrusted(address indexed usr);

    /*///////////////////////////////////////////////////////////////
                              TRUST STORAGE
    //////////////////////////////////////////////////////////////*/

    mapping(address => bool) public isTrusted;

    /*///////////////////////////////////////////////////////////////
                         TRUST MODIFIER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function trust(address user) public requiresTrust {
        isTrusted[user] = true;

        emit UserTrusted(user);
    }

    function distrust(address user) public requiresTrust {
        isTrusted[user] = false;

        emit UserDistrusted(user);
    }

    /*///////////////////////////////////////////////////////////////
                              TRUST LOGIC
    //////////////////////////////////////////////////////////////*/

    modifier requiresTrust() {
        require(isTrusted[msg.sender], "UNTRUSTED");

        _;
    }
}
