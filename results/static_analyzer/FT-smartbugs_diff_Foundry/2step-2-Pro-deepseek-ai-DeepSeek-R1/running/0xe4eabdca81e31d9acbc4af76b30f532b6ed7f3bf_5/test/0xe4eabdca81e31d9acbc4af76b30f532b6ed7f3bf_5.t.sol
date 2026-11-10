// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe4eabdca81e31d9acbc4af76b30f532b6ed7f3bf.sol";

contract HoneySecurityTest is Test {
    Honey public honey;
    address public user = makeAddr("user");
    
    event FreebieClaimed(address indexed user, bool success);

    function setUp() public {
        honey = new Honey();
    }

    function test_GetFreebieZeroValue() public {
        console.log("--- BEFORE-Trigger Contract Balance ---");
        uint256 contractBalanceBefore = address(honey).balance;
        console.log("Contract Balance Before:", contractBalanceBefore);

        console.log("--- Trigger GetFreebie ---");
        // Validate event with correct emitter address and topic flags
        vm.expectEmit(true, true, false, true, address(honey));
        emit FreebieClaimed(user, false);
        
        vm.prank(user);
        honey.GetFreebie{value: 0}();
        
        console.log("--- AFTER-Trigger Contract Balance ---");
        uint256 contractBalanceAfter = address(honey).balance;
        console.log("Contract Balance After:", contractBalanceAfter);

        assertEq(contractBalanceAfter, contractBalanceBefore, "Balance should remain unchanged");
        
        if (contractBalanceAfter != contractBalanceBefore) {
            console.log("Vulnerability Exists: Contract balance changed unexpectedly after exploitation");
        } else {
            console.log("Vulnerability not Exist: Contract balance remains unchanged as expected after failed freebie claim");
        }
    }
}