// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.10;

import {DSTestPlus} from "../utils/DSTestPlus.sol";
import {ERC20} from "../../tokens/ERC20.sol";
import {MockERC20} from "../utils/mocks/MockERC20.sol";

contract ERC20DeployBenchmarkTest is DSTestPlus {
    MockERC20 token;

    function setUp() public {
      token = new MockERC20("A", "B", 18);
    }

    function testDeploy() public {
      MockERC20 a = new MockERC20("A", "B", 18);
    }
}

contract ERC20TransferBenchmarkTest is DSTestPlus {
    // 0xAAAA has 1000 tokens
    // 0xBBBB has 1000 tokens
    // 0xCCCC has no token

    MockERC20 token;

    function setUp() public {
      token = new MockERC20("A", "B", 18);
      token.mint(address(0xAAAA), 1000 ether);
      token.mint(address(0xBBBB), 1000 ether);
    }

    function testTransferWhenReceiverOwnTokens() public {
      hevm.prank(address(0xAAAA));
      token.transfer(address(0xBBBB), 1 ether);
    }

    function testTransferWhenReceiverHasZeroTokens() public {
      hevm.prank(address(0xAAAA));
      token.transfer(address(0xCCCC), 1 ether);
    }

    function testTransferWhenSenderEmptyItsPocketsAndReceiverHasTokens() public {
      hevm.prank(address(0xAAAA));
      token.transfer(address(0xBBBB), 1000 ether);
    }

    function testTransferWhenSenderEmptyItsPocketsAndReceiverHasZeroTokens() public {
      hevm.prank(address(0xAAAA));
      token.transfer(address(0xCCCC), 1000 ether);
    }
}