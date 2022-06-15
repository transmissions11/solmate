// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import {DSTestPlus} from "./utils/DSTestPlus.sol";

import {FixedPointMathLib} from "../utils/FixedPointMathLib.sol";

contract FixedPointMathLibTest is DSTestPlus {
    function testExpWad() public {
        assertEq(FixedPointMathLib.expWad(-42139678854452767551), 0);

        assertEq(FixedPointMathLib.expWad(-3e18), 49787068367863942);
        assertEq(FixedPointMathLib.expWad(-2e18), 135335283236612691);
        assertEq(FixedPointMathLib.expWad(-1e18), 367879441171442321);

        assertEq(FixedPointMathLib.expWad(-0.5e18), 606530659712633423);
        assertEq(FixedPointMathLib.expWad(-0.3e18), 740818220681717866);

        assertEq(FixedPointMathLib.expWad(0), 1000000000000000000);

        assertEq(FixedPointMathLib.expWad(0.3e18), 1349858807576003103);
        assertEq(FixedPointMathLib.expWad(0.5e18), 1648721270700128146);

        assertEq(FixedPointMathLib.expWad(1e18), 2718281828459045235);
        assertEq(FixedPointMathLib.expWad(2e18), 7389056098930650227);
        assertEq(
            FixedPointMathLib.expWad(3e18),
            20085536923187667741
            // True value: 20085536923187667740.92
        );

        assertEq(
            FixedPointMathLib.expWad(10e18),
            220264657948067165169_80
            // True value: 22026465794806716516957.90
            // Relative error 9.987984547746668e-22
        );

        assertEq(
            FixedPointMathLib.expWad(50e18),
            5184705528587072464_148529318587763226117
            // True value: 5184705528587072464_087453322933485384827.47
            // Relative error: 1.1780031733243328e-20
        );

        assertEq(
            FixedPointMathLib.expWad(100e18),
            268811714181613544841_34666106240937146178367581647816351662017
            // True value: 268811714181613544841_26255515800135873611118773741922415191608
            // Relative error: 3.128803544297531e-22
        );

        assertEq(
            FixedPointMathLib.expWad(135305999368893231588),
            578960446186580976_50144101621524338577433870140581303254786265309376407432913
            // True value: 578960446186580976_49816762928942336782129491980154662247847962410455084893091
            // Relative error: 5.653904247484822e-21
        );
    }

    function testMulWadDown() public {
        assertEq(FixedPointMathLib.mulWadDown(2.5e18, 0.5e18), 1.25e18);
        assertEq(FixedPointMathLib.mulWadDown(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.mulWadDown(369, 271), 0);
    }

    function testMulWadDownEdgeCases() public {
        assertEq(FixedPointMathLib.mulWadDown(0, 1e18), 0);
        assertEq(FixedPointMathLib.mulWadDown(1e18, 0), 0);
        assertEq(FixedPointMathLib.mulWadDown(0, 0), 0);
    }

    function testMulWadUp() public {
        assertEq(FixedPointMathLib.mulWadUp(2.5e18, 0.5e18), 1.25e18);
        assertEq(FixedPointMathLib.mulWadUp(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.mulWadUp(369, 271), 1);
    }

    function testMulWadUpEdgeCases() public {
        assertEq(FixedPointMathLib.mulWadUp(0, 1e18), 0);
        assertEq(FixedPointMathLib.mulWadUp(1e18, 0), 0);
        assertEq(FixedPointMathLib.mulWadUp(0, 0), 0);
    }

    function testDivWadDown() public {
        assertEq(FixedPointMathLib.divWadDown(1.25e18, 0.5e18), 2.5e18);
        assertEq(FixedPointMathLib.divWadDown(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.divWadDown(2, 100000000000000e18), 0);
    }

    function testDivWadDownEdgeCases() public {
        assertEq(FixedPointMathLib.divWadDown(0, 1e18), 0);
    }

    function testFailDivWadDownZeroDenominator() public pure {
        FixedPointMathLib.divWadDown(1e18, 0);
    }

    function testDivWadUp() public {
        assertEq(FixedPointMathLib.divWadUp(1.25e18, 0.5e18), 2.5e18);
        assertEq(FixedPointMathLib.divWadUp(3e18, 1e18), 3e18);
        assertEq(FixedPointMathLib.divWadUp(2, 100000000000000e18), 1);
    }

    function testDivWadUpEdgeCases() public {
        assertEq(FixedPointMathLib.divWadUp(0, 1e18), 0);
    }

    function testFailDivWadUpZeroDenominator() public pure {
        FixedPointMathLib.divWadUp(1e18, 0);
    }

    function testMulDivDown() public {
        assertEq(FixedPointMathLib.mulDivDown(2.5e27, 0.5e27, 1e27), 1.25e27);
        assertEq(FixedPointMathLib.mulDivDown(2.5e18, 0.5e18, 1e18), 1.25e18);
        assertEq(FixedPointMathLib.mulDivDown(2.5e8, 0.5e8, 1e8), 1.25e8);
        assertEq(FixedPointMathLib.mulDivDown(369, 271, 1e2), 999);

        assertEq(FixedPointMathLib.mulDivDown(1e27, 1e27, 2e27), 0.5e27);
        assertEq(FixedPointMathLib.mulDivDown(1e18, 1e18, 2e18), 0.5e18);
        assertEq(FixedPointMathLib.mulDivDown(1e8, 1e8, 2e8), 0.5e8);

        assertEq(FixedPointMathLib.mulDivDown(2e27, 3e27, 2e27), 3e27);
        assertEq(FixedPointMathLib.mulDivDown(3e18, 2e18, 3e18), 2e18);
        assertEq(FixedPointMathLib.mulDivDown(2e8, 3e8, 2e8), 3e8);
    }

    function testMulDivDownEdgeCases() public {
        assertEq(FixedPointMathLib.mulDivDown(0, 1e18, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivDown(1e18, 0, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivDown(0, 0, 1e18), 0);
    }

    function testFailMulDivDownZeroDenominator() public pure {
        FixedPointMathLib.mulDivDown(1e18, 1e18, 0);
    }

    function testMulDivUp() public {
        assertEq(FixedPointMathLib.mulDivUp(2.5e27, 0.5e27, 1e27), 1.25e27);
        assertEq(FixedPointMathLib.mulDivUp(2.5e18, 0.5e18, 1e18), 1.25e18);
        assertEq(FixedPointMathLib.mulDivUp(2.5e8, 0.5e8, 1e8), 1.25e8);
        assertEq(FixedPointMathLib.mulDivUp(369, 271, 1e2), 1000);

        assertEq(FixedPointMathLib.mulDivUp(1e27, 1e27, 2e27), 0.5e27);
        assertEq(FixedPointMathLib.mulDivUp(1e18, 1e18, 2e18), 0.5e18);
        assertEq(FixedPointMathLib.mulDivUp(1e8, 1e8, 2e8), 0.5e8);

        assertEq(FixedPointMathLib.mulDivUp(2e27, 3e27, 2e27), 3e27);
        assertEq(FixedPointMathLib.mulDivUp(3e18, 2e18, 3e18), 2e18);
        assertEq(FixedPointMathLib.mulDivUp(2e8, 3e8, 2e8), 3e8);
    }

    function testMulDivUpEdgeCases() public {
        assertEq(FixedPointMathLib.mulDivUp(0, 1e18, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivUp(1e18, 0, 1e18), 0);
        assertEq(FixedPointMathLib.mulDivUp(0, 0, 1e18), 0);
    }

    function testFailMulDivUpZeroDenominator() public pure {
        FixedPointMathLib.mulDivUp(1e18, 1e18, 0);
    }

    function testLnWad() public {
        assertEq(FixedPointMathLib.lnWad(1e18), 0);

        // Actual: 999999999999999999.8674576…
        assertEq(FixedPointMathLib.lnWad(2718281828459045235), 999999999999999999);

        // Actual: 2461607324344817917.963296…
        assertEq(FixedPointMathLib.lnWad(11723640096265400935), 2461607324344817918);
    }

    function testLnWadSmall() public {
        // Actual: -41446531673892822312.3238461…
        assertEq(FixedPointMathLib.lnWad(1), -41446531673892822313);

        // Actual: -37708862055609454006.40601608…
        assertEq(FixedPointMathLib.lnWad(42), -37708862055609454007);

        // Actual: -32236191301916639576.251880365581…
        assertEq(FixedPointMathLib.lnWad(1e4), -32236191301916639577);

        // Actual: -20723265836946411156.161923092…
        assertEq(FixedPointMathLib.lnWad(1e9), -20723265836946411157);
    }

    function testLnWadBig() public {
        // Actual: 135305999368893231589.070344787…
        assertEq(FixedPointMathLib.lnWad(2**255 - 1), 135305999368893231589);

        // Actual: 76388489021297880288.605614463571…
        assertEq(FixedPointMathLib.lnWad(2**170), 76388489021297880288);

        // Actual: 47276307437780177293.081865…
        assertEq(FixedPointMathLib.lnWad(2**128), 47276307437780177293);
    }

    function testLnWadNegative() public {
        // TODO: Blocked on <https://github.com/gakonst/foundry/issues/864>
        // hevm.expectRevert(FixedPointMathLib.LnNegativeUndefined.selector);
        // FixedPointMathLib.lnWad(-1);
        // FixedPointMathLib.lnWad(-2**255);
    }

    function testLnWadOverflow() public {
        // TODO: Blocked on <https://github.com/gakonst/foundry/issues/864>
        // hevm.expectRevert(FixedPointMathLib.Overflow.selector);
        // FixedPointMathLib.lnWad(0);
    }

    function testRPow() public {
        assertEq(FixedPointMathLib.rpow(2e27, 2, 1e27), 4e27);
        assertEq(FixedPointMathLib.rpow(2e18, 2, 1e18), 4e18);
        assertEq(FixedPointMathLib.rpow(2e8, 2, 1e8), 4e8);
        assertEq(FixedPointMathLib.rpow(8, 3, 1), 512);
    }

    function testSqrt() public {
        assertEq(FixedPointMathLib.sqrt(0), 0);
        assertEq(FixedPointMathLib.sqrt(1), 1);
        assertEq(FixedPointMathLib.sqrt(2704), 52);
        assertEq(FixedPointMathLib.sqrt(110889), 333);
        assertEq(FixedPointMathLib.sqrt(32239684), 5678);
    }

    function testLog2() public {
        assertEq(FixedPointMathLib.log2(2), 1);
        assertEq(FixedPointMathLib.log2(4), 2);
        assertEq(FixedPointMathLib.log2(1024), 10);
        assertEq(FixedPointMathLib.log2(1048576), 20);
        assertEq(FixedPointMathLib.log2(1073741824), 30);
    }

    function testFuzzMulWadDown(uint256 x, uint256 y) public {
        // Ignore cases where x * y overflows.
        unchecked {
            if (x != 0 && (x * y) / x != y) return;
        }

        assertEq(FixedPointMathLib.mulWadDown(x, y), (x * y) / 1e18);
    }

    function testFailFuzzMulWadDownOverflow(uint256 x, uint256 y) public pure {
        // Ignore cases where x * y does not overflow.
        unchecked {
            if ((x * y) / x == y) revert();
        }

        FixedPointMathLib.mulWadDown(x, y);
    }

    function testFuzzMulWadUp(uint256 x, uint256 y) public {
        // Ignore cases where x * y overflows.
        unchecked {
            if (x != 0 && (x * y) / x != y) return;
        }

        assertEq(FixedPointMathLib.mulWadUp(x, y), x * y == 0 ? 0 : (x * y - 1) / 1e18 + 1);
    }

    function testFailFuzzMulWadUpOverflow(uint256 x, uint256 y) public pure {
        // Ignore cases where x * y does not overflow.
        unchecked {
            if ((x * y) / x == y) revert();
        }

        FixedPointMathLib.mulWadUp(x, y);
    }

    function testFuzzDivWadDown(uint256 x, uint256 y) public {
        // Ignore cases where x * WAD overflows or y is 0.
        unchecked {
            if (y == 0 || (x != 0 && (x * 1e18) / 1e18 != x)) return;
        }

        assertEq(FixedPointMathLib.divWadDown(x, y), (x * 1e18) / y);
    }

    function testFailFuzzDivWadDownOverflow(uint256 x, uint256 y) public pure {
        // Ignore cases where x * WAD does not overflow or y is 0.
        unchecked {
            if (y == 0 || (x * 1e18) / 1e18 == x) revert();
        }

        FixedPointMathLib.divWadDown(x, y);
    }

    function testFailFuzzDivWadDownZeroDenominator(uint256 x) public pure {
        FixedPointMathLib.divWadDown(x, 0);
    }

    function testFuzzDivWadUp(uint256 x, uint256 y) public {
        // Ignore cases where x * WAD overflows or y is 0.
        unchecked {
            if (y == 0 || (x != 0 && (x * 1e18) / 1e18 != x)) return;
        }

        assertEq(FixedPointMathLib.divWadUp(x, y), x == 0 ? 0 : (x * 1e18 - 1) / y + 1);
    }

    function testFailFuzzDivWadUpOverflow(uint256 x, uint256 y) public pure {
        // Ignore cases where x * WAD does not overflow or y is 0.
        unchecked {
            if (y == 0 || (x * 1e18) / 1e18 == x) revert();
        }

        FixedPointMathLib.divWadUp(x, y);
    }

    function testFailFuzzDivWadUpZeroDenominator(uint256 x) public pure {
        FixedPointMathLib.divWadUp(x, 0);
    }

    function testFuzzMulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public {
        // Ignore cases where x * y overflows or denominator is 0.
        unchecked {
            if (denominator == 0 || (x != 0 && (x * y) / x != y)) return;
        }

        assertEq(FixedPointMathLib.mulDivDown(x, y, denominator), (x * y) / denominator);
    }

    function testFailFuzzMulDivDownOverflow(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public pure {
        // Ignore cases where x * y does not overflow or denominator is 0.
        unchecked {
            if (denominator == 0 || (x * y) / x == y) revert();
        }

        FixedPointMathLib.mulDivDown(x, y, denominator);
    }

    function testFailFuzzMulDivDownZeroDenominator(uint256 x, uint256 y) public pure {
        FixedPointMathLib.mulDivDown(x, y, 0);
    }

    function testFuzzMulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public {
        // Ignore cases where x * y overflows or denominator is 0.
        unchecked {
            if (denominator == 0 || (x != 0 && (x * y) / x != y)) return;
        }

        assertEq(FixedPointMathLib.mulDivUp(x, y, denominator), x * y == 0 ? 0 : (x * y - 1) / denominator + 1);
    }

    function testFailFuzzMulDivUpOverflow(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public pure {
        // Ignore cases where x * y does not overflow or denominator is 0.
        unchecked {
            if (denominator == 0 || (x * y) / x == y) revert();
        }

        FixedPointMathLib.mulDivUp(x, y, denominator);
    }

    function testFailFuzzMulDivUpZeroDenominator(uint256 x, uint256 y) public pure {
        FixedPointMathLib.mulDivUp(x, y, 0);
    }

    function testFuzzSqrt(uint256 x) public {
        uint256 root = FixedPointMathLib.sqrt(x);
        uint256 next = root + 1;

        // Ignore cases where next * next overflows.
        unchecked {
            if (next * next < next) return;
        }

        assertTrue(root * root <= x && next * next > x);
    }

    function testFuzzLog2() public {
        for (uint256 i = 1; i < 255; i++) {
            assertEq(FixedPointMathLib.log2((1 << i) - 1), i - 1);
            assertEq(FixedPointMathLib.log2((1 << i)), i);
            assertEq(FixedPointMathLib.log2((1 << i) + 1), i);
        }
    }
}
