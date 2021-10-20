// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity >=0.7.0;

contract GenericUser {
    function tryCall(address someContract, bytes memory someData)
        external
        returns (bool success, bytes memory returnData)
    {
        (success, returnData) = someContract.call(someData);
    }

    function call(address someContract, bytes memory someData) external returns (bytes memory returnData) {
        bool success;
        (success, returnData) = someContract.call(someData);

        if (success) {
            if (returnData.length > 0) {
                assembly {
                    let returnDataSize := mload(returnData)
                    revert(add(32, returnData), returnDataSize)
                }
            } else {
                revert("NO_RETURN_DATA");
            }
        }
    }
}
