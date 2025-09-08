// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import {Test, console2} from 'forge-std/Test.sol';
import {SafePct} from 'contracts/utils/library/SafePct.sol';

contract AllTest is Test {
    uint256[] selectors;
    uint8 selectorPosition;

    function setUp() external {
    }

    function testOverflowWithMulDiv(uint256 x, uint256 y, uint256 z) external pure {
        uint256 result = SafePct.mulDiv(x,y,z);
        console2.log("Result: ", result);
    }



}