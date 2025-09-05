// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import {Test, console2} from 'forge-std/Test.sol';

contract AllTest is Test {
    uint256[] selectors;
    uint8 selectorPosition;

    function setUp() external {
    }

    function testSomething() external {
        for(uint i = 0 ; i < 256; i++)
        selectors.push(i);
        selectorPosition = uint8(selectors.length);
        if(selectorPosition == 0){
            console2.log("Position 0 for index: ", selectorPosition, selectors.length);
            revert();
        }
    }

}