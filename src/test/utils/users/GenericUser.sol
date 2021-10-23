// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.7.0;

contract GenericUser {
    function tryCall(address target, bytes memory data) public virtual returns (bool success, bytes memory returnData) {
        (success, returnData) = target.call(data);
    }

    function call(address target, bytes memory data) public virtual returns (bytes memory returnData) {
        bool success;
        (success, returnData) = target.call(data);

        if (!success) {
            if (returnData.length > 0) {
                assembly {
                    let returnDataSize := mload(returnData)
                    revert(add(32, returnData), returnDataSize)
                }
            } else {
                revert("REVERTED_WITHOUT_MESSAGE");
            }
        }
    }
}
