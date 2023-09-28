// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {ERC6909} from "../../../tokens/ERC6909.sol";

contract MockERC6909 is ERC6909 {
    function mint(
        address receiver,
        uint256 id,
        uint256 amount
    ) public virtual {
        _mint(receiver, id, amount);
    }

    function burn(
        address sender,
        uint256 id,
        uint256 amount
    ) public virtual {
        _burn(sender, id, amount);
    }
}
