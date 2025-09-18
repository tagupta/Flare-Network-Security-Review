// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import {Test, console2} from 'forge-std/Test.sol';
import {SafePct} from 'contracts/utils/library/SafePct.sol';
import {MathUtils} from 'contracts/utils/library/MathUtils.sol';
import {SafeMath64} from 'contracts/utils/library/SafeMath64.sol';

contract AllTest is Test {
    uint256[] selectors;
    uint8 selectorPosition;

    function setUp() external {
    }

    function testOverflowWithMulDiv(uint256 x, uint256 y, uint256 z) external pure {
        uint256 result = SafePct.mulDiv(x,y,z);
        console2.log("Result: ", result);
    }

    function testOverfowForRoundUp(uint256 x, uint256 rounding) external pure{
        uint256 result = MathUtils.roundUp(x,rounding);
        assertGt(result, 0, "Result is always greater than zero");
    }

    function testOverflowWithUint64(int256 a) external pure {
        vm.assume(a >= 0 &&  a <= int256(uint256(type(uint64).max)));
        uint64 result = SafeMath64.toUint64(a);
        assert(result >= 0);
    }

    function testErrorWithInt64(uint256 a) external pure {
        vm.assume(a <= uint256(int256(type(int64).max)));
        int64 result = SafeMath64.toInt64(a);
        assert(result >= type(int64).min);  // >= -9223372036854775808
        assert(result <= type(int64).max);  // <= 9223372036854775807

    }



}