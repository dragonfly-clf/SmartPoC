// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/EKARTINU.sol";

contract ReturnValueMockToken {
    mapping(address => uint256) public balanceOf;

    function setBalance(address account, uint256 amount) external {
        balanceOf[account] = amount;
    }

    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract EKARTINUTest is Test {
    EKARTINU public ekart;
    ReturnValueMockToken public mockToken;
    address public owner = makeAddr("owner");

    function setUp() public {
        vm.startPrank(owner);
        ekart = new EKARTINU();
        vm.stopPrank();

        mockToken = new ReturnValueMockToken();
        mockToken.setBalance(address(ekart), 100 ether);
    }

    function testTokenExtractionIgnoresTransferReturnValue() public {
        // Pre-state snapshot
        console.log("--- BEFORE-Trigger State ---");
        uint256 ekartBalanceBefore = mockToken.balanceOf(address(ekart));
        uint256 ownerBalanceBefore = mockToken.balanceOf(owner);
        console.log("EKART contract currency balance:", ekartBalanceBefore);
        console.log("Contract owner currency balance:", ownerBalanceBefore);

        // Trigger vulnerability
        console.log("--- Trigger Action: extractLostToken ---");
        vm.prank(owner);
        ekart.extractLostToken(address(mockToken));

        // Post-state snapshot
        console.log("--- AFTER-Trigger State ---");
        uint256 ekartBalanceAfter = mockToken.balanceOf(address(ekart));
        uint256 ownerBalanceAfter = mockToken.balanceOf(owner);
        console.log("EKART contract currency balance:", ekartBalanceAfter);
        console.log("Contract owner currency balance:", ownerBalanceAfter);

        // Compare outcomes
        bool stateUnchanged = (ekartBalanceAfter == ekartBalanceBefore) && 
                             (ownerBalanceAfter == ownerBalanceBefore);
        
        console.log("--- Result Verification ---");
        console.log("State changed:", stateUnchanged ? "No" : "Yes");
        console.log("Vulnerability exploited:", stateUnchanged ? "Yes" : "No");
        
        // Final verdict
        if (stateUnchanged) {
            console.log("Vulnerability Exists: extractLostToken ignores transfer return value");
        } else {
            console.log("Vulnerability not Exist: State changed during extraction");
        }

        // Original validation assertions
        assertEq(ekartBalanceAfter, 100 ether, "Balance of EKART contract should be 100 ether");
        assertEq(ownerBalanceAfter, 0, "Balance of owner should be 0");
    }
}