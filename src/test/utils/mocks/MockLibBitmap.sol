// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import {LibBitmap} from "../../../utils/LibBitmap.sol";

contract MockLibBitmap {
    using LibBitmap for LibBitmap.Bitmap;
    LibBitmap.Bitmap bitmap;

    function get(uint256 index) public view returns (bool result) {
        result = bitmap.get(index);
    }

    function set(uint256 index) public {
        bitmap.set(index);
    }

    function unset(uint256 index) public {
        bitmap.unset(index);
    }

    function toggle(uint256 index) public {
        bitmap.toggle(index);
    }

    function setTo(uint256 index, bool shouldSet) public {
        bitmap.setTo(index, shouldSet);
    }
}
