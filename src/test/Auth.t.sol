// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockAuthChild} from "./utils/mocks/MockAuthChild.sol";
import {MockAuthority} from "./utils/mocks/MockAuthority.sol";

import {Authority} from "../auth/Auth.sol";

contract OutOfOrderAuthority is Authority {
    function canCall(
        address,
        address,
        bytes4
    ) public pure override returns (bool) {
        revert("OUT_OF_ORDER");
    }
}

contract AuthTest is DSTestPlus {
    MockAuthChild mockAuthChild;

    function setUp() public {
        mockAuthChild = new MockAuthChild();
    }

    function testSetOwnerAsOwner() public {
        mockAuthChild.setOwner(address(0xBEEF));
        assertEq(mockAuthChild.owner(), address(0xBEEF));
    }

    function testSetAuthorityAsOwner() public {
        mockAuthChild.setAuthority(Authority(address(0xBEEF)));
        assertEq(address(mockAuthChild.authority()), address(0xBEEF));
    }

    function testCallFunctionAsOwner() public {
        mockAuthChild.updateFlag();
    }

    function testSetOwnerWithPermissiveAuthority() public {
        mockAuthChild.setAuthority(new MockAuthority(true));
        mockAuthChild.setOwner(address(0));
        mockAuthChild.setOwner(address(this));
    }

    function testSetAuthorityWithPermissiveAuthority() public {
        mockAuthChild.setAuthority(new MockAuthority(true));
        mockAuthChild.setOwner(address(0));
        mockAuthChild.setAuthority(Authority(address(0xBEEF)));
    }

    function testCallFunctionWithPermissiveAuthority() public {
        mockAuthChild.setAuthority(new MockAuthority(true));
        mockAuthChild.setOwner(address(0));
        mockAuthChild.updateFlag();
    }

    function testSetAuthorityAsOwnerWithOutOfOrderAuthority() public {
        mockAuthChild.setAuthority(new OutOfOrderAuthority());
        mockAuthChild.setAuthority(new MockAuthority(true));
    }

    function testFailSetOwnerAsNonOwner() public {
        mockAuthChild.setOwner(address(0));
        mockAuthChild.setOwner(address(0xBEEF));
    }

    function testFailSetAuthorityAsNonOwner() public {
        mockAuthChild.setOwner(address(0));
        mockAuthChild.setAuthority(Authority(address(0xBEEF)));
    }

    function testFailCallFunctionAsNonOwner() public {
        mockAuthChild.setOwner(address(0));
        mockAuthChild.updateFlag();
    }

    function testFailSetOwnerWithRestrictiveAuthority() public {
        mockAuthChild.setAuthority(new MockAuthority(false));
        mockAuthChild.setOwner(address(0));
        mockAuthChild.setOwner(address(this));
    }

    function testFailSetAuthorityWithRestrictiveAuthority() public {
        mockAuthChild.setAuthority(new MockAuthority(false));
        mockAuthChild.setOwner(address(0));
        mockAuthChild.setAuthority(Authority(address(0xBEEF)));
    }

    function testFailCallFunctionWithRestrictiveAuthority() public {
        mockAuthChild.setAuthority(new MockAuthority(false));
        mockAuthChild.setOwner(address(0));
        mockAuthChild.updateFlag();
    }

    function testFailSetOwnerAsOwnerWithOutOfOrderAuthority() public {
        mockAuthChild.setAuthority(new OutOfOrderAuthority());
        mockAuthChild.setOwner(address(0));
    }

    function testFailCallFunctionAsOwnerWithOutOfOrderAuthority() public {
        mockAuthChild.setAuthority(new OutOfOrderAuthority());
        mockAuthChild.updateFlag();
    }

    function testFuzzSetOwnerAsOwner(address newOwner) public {
        mockAuthChild.setOwner(newOwner);
        assertEq(mockAuthChild.owner(), newOwner);
    }

    function testFuzzSetAuthorityAsOwner(Authority newAuthority) public {
        mockAuthChild.setAuthority(newAuthority);
        assertEq(address(mockAuthChild.authority()), address(newAuthority));
    }

    function testFuzzSetOwnerWithPermissiveAuthority(address deadOwner, address newOwner) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setAuthority(new MockAuthority(true));
        mockAuthChild.setOwner(deadOwner);
        mockAuthChild.setOwner(newOwner);
    }

    function testFuzzSetAuthorityWithPermissiveAuthority(address deadOwner, Authority newAuthority) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setAuthority(new MockAuthority(true));
        mockAuthChild.setOwner(deadOwner);
        mockAuthChild.setAuthority(newAuthority);
    }

    function testFuzzCallFunctionWithPermissiveAuthority(address deadOwner) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setAuthority(new MockAuthority(true));
        mockAuthChild.setOwner(deadOwner);
        mockAuthChild.updateFlag();
    }

    function testFailFuzzSetOwnerAsNonOwner(address deadOwner, address newOwner) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setOwner(deadOwner);
        mockAuthChild.setOwner(newOwner);
    }

    function testFailFuzzSetAuthorityAsNonOwner(address deadOwner, Authority newAuthority) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setOwner(deadOwner);
        mockAuthChild.setAuthority(newAuthority);
    }

    function testFailFuzzCallFunctionAsNonOwner(address deadOwner) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setOwner(deadOwner);
        mockAuthChild.updateFlag();
    }

    function testFailFuzzSetOwnerWithRestrictiveAuthority(address deadOwner, address newOwner) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setAuthority(new MockAuthority(false));
        mockAuthChild.setOwner(deadOwner);
        mockAuthChild.setOwner(newOwner);
    }

    function testFailFuzzSetAuthorityWithRestrictiveAuthority(address deadOwner, Authority newAuthority) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setAuthority(new MockAuthority(false));
        mockAuthChild.setOwner(deadOwner);
        mockAuthChild.setAuthority(newAuthority);
    }

    function testFailFuzzCallFunctionWithRestrictiveAuthority(address deadOwner) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setAuthority(new MockAuthority(false));
        mockAuthChild.setOwner(deadOwner);
        mockAuthChild.updateFlag();
    }

    function testFailFuzzSetOwnerAsOwnerWithOutOfOrderAuthority(address deadOwner) public {
        if (deadOwner == address(this)) deadOwner = address(0);

        mockAuthChild.setAuthority(new OutOfOrderAuthority());
        mockAuthChild.setOwner(deadOwner);
    }
}
