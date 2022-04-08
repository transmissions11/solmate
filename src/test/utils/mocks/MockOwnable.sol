// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {Ownable} from "../../../auth/Ownable.sol";

contract MockOwnable is Ownable(msg.sender) {
    bool public flag;

    function updateFlag() public virtual onlyOwner {
        flag = true;
    }
}
