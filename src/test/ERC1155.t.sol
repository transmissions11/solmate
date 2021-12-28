// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {DSInvariantTest} from "./utils/DSInvariantTest.sol";

import {MockERC1155} from "./utils/mocks/MockERC1155.sol";
import {ERC1155User} from "./utils/users/ERC1155User.sol";

contract ERC1155Test is DSTestPlus {
    MockERC1155 token;

    function setUp() public {
        token = new MockERC1155();
    }

    function testMint() public {
        token.mint(address(0xBEEF), 1, 1, "");

        assertEq(token.balanceOf(address(0xBEEF), 1), 1);
    }

    function testBatchMint(
        address usr,
        uint256[] memory ids,
        uint amount
    ) public {
        if (usr == address(0)) return;
        
        uint len = ids.length;
        uint256[] memory amounts = new uint256[](len);
        address[] memory owners = new address[](len);

        for (uint i = 0; i < len; i++) {
            //if ids array has any dupes amounts will not be correct
            for (uint256 j = 0; j < i; j++) {
                if (ids[i] == ids[j]) return;
            }
            amounts[i] = amount;
            owners[i] = usr;
        }

        token.batchMint(usr, ids, amounts, "");

        assertUintArrayEq(token.balanceOfBatch(owners, ids), amounts);
    }

    function testBatchBurn(
        address usr,
        uint256[] memory ids,
        uint amount
    ) public {
        if (usr == address(0)) return;

        uint len = ids.length;
        uint256[] memory amounts = new uint256[](len);
        uint256[] memory zeroAmounts = new uint256[](len);        
        address[] memory owners = new address[](len);

        for (uint i = 0; i < len; i++) {
            //if ids array has any dupes amounts will not be correct
            for (uint256 j = 0; j < i; j++) {
                if (ids[i] == ids[j]) return;
            }
            amounts[i] = amount;
            zeroAmounts[i] = 0;
            owners[i] = usr;
        }

        token.batchMint(usr, ids, amounts, "");

        assertUintArrayEq(token.balanceOfBatch(owners, ids), amounts);

        token.batchBurn(usr, ids, amounts);

        assertUintArrayEq(token.balanceOfBatch(owners, ids), zeroAmounts);
    }

    function testSafeBatchTransferFromWithApproval(
        uint256[] memory ids,
        uint amount
    ) public {
        ERC1155User usr = new ERC1155User(token);
        ERC1155User receiver = new ERC1155User(token);
        ERC1155User operator = new ERC1155User(token);

        uint len = ids.length;

        uint256[] memory amounts = new uint256[](len);
        uint256[] memory zeroAmounts = new uint256[](len);
        address[] memory usrs = new address[](len);
        address[] memory receivers = new address[](len);

        for (uint i = 0; i < len; i++) {
            //if ids array has any dupes amounts will not be correct
            for (uint256 j = 0; j < i; j++) {
                if (ids[i] == ids[j]) return;
            }
            amounts[i] = amount;
            receivers[i] = address(receiver);
            usrs[i] = address(usr);
            zeroAmounts[i] = 0;
        }
        
        //mint tokens to usr
        token.batchMint(address(usr), ids, amounts, "");

        // The operator should not be able to transfer the unapproved token
        try operator.safeBatchTransferFrom(address(usr), address(receiver), ids, amounts, "") {
            fail();
        } catch Error(string memory error) {
            assertEq(error, "INVALID_OPERATOR");
        }

        usr.setApprovalForAll(address(operator), true);
        operator.safeBatchTransferFrom(address(usr), address(receiver), ids, amounts, "");

        assertUintArrayEq(token.balanceOfBatch(usrs, ids), zeroAmounts);
        assertUintArrayEq(token.balanceOfBatch(receivers, ids), amounts);

        // The operator now should not be able to transfer the token
        // since it was not approved by the current user
        try operator.safeBatchTransferFrom(address(receiver), address(usr), ids, amounts, "") {
            fail();
        } catch Error(string memory error) {
            assertEq(error, "INVALID_OPERATOR");
        }
    }
}
