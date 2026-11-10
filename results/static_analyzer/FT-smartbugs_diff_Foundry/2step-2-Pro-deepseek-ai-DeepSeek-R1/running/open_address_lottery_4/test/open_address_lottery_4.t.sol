// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/open_address_lottery.sol";

contract OpenAddressLotterySelfdestructTest is Test {
    OpenAddressLottery lottery;
    address owner = makeAddr("owner");
    address nonOwner = makeAddr("nonOwner");

    function setUp() public {
        vm.prank(owner);
        lottery = new OpenAddressLottery();
        vm.deal(address(lottery), 1 ether);
    }

    // Test that non-owner cannot call kill()
    function testNonOwnerCannotKill() public {
        console2.log("--- BEFORE-Trigger Contract Balance ---");
        uint256 contractBalanceBefore = address(lottery).balance;
        uint256 ownerBalanceBefore = owner.balance;
        console2.log("Contract Balance:", contractBalanceBefore);
        console2.log("Owner Balance:", ownerBalanceBefore);

        console2.log("--- Trigger nonOwner kills ---");
        vm.prank(nonOwner);
        vm.expectRevert();
        lottery.kill();

        console2.log("--- AFTER-Trigger Contract Balance ---");
        uint256 contractBalanceAfter = address(lottery).balance;
        uint256 ownerBalanceAfter = owner.balance;
        console2.log("Contract Balance:", contractBalanceAfter);
        console2.log("Owner Balance:", ownerBalanceAfter);

        // Check for state changes
        bool isStateChanged = (contractBalanceBefore != contractBalanceAfter) || (ownerBalanceBefore != ownerBalanceAfter);
        
        if (!isStateChanged) {
            console2.log("Vulnerability not Exist: No state change occurred");
            console2.log("--- Test Result ---");
            console2.log("Non-owner kill call failed and state remains unchanged");
        } else {
            console2.log("Vulnerability Exists: Unauthorized state change detected");
            console2.log("--- Test Result ---");
            console2.log("Critical: Non-owner was able to modify contract state");
        }

        // Final verdict declaration (exactly one final line)
        assertFalse(isStateChanged);
        console2.log("Vulnerability not Exist: Non-owner cannot access kill function"); 
    }

    // Test that owner can selfdestruct contract and receive funds
    function testOwnerCanSelfdestruct() public {
        console2.log("--- BEFORE-Trigger Contract Balance ---");
        uint256 contractBalanceBefore = address(lottery).balance;
        uint256 ownerBalanceBefore = owner.balance;
        console2.log("Contract Balance:", contractBalanceBefore);
        console2.log("Owner Balance:", ownerBalanceBefore);

        console2.log("--- Trigger owner kills ---");
        vm.prank(owner);
        lottery.kill();

        console2.log("--- AFTER-Trigger Contract Balance ---");
        uint256 contractBalanceAfter = address(lottery).balance;
        uint256 ownerBalanceAfter = owner.balance;
        console2.log("Contract Balance:", contractBalanceAfter);
        console2.log("Owner Balance:", ownerBalanceAfter);

        // Check for required state changes
        bool fundsTransferred = (ownerBalanceAfter == ownerBalanceBefore + contractBalanceBefore) && 
                               (contractBalanceAfter == 0);
        bool noChange = (contractBalanceAfter == contractBalanceBefore) && 
                        (ownerBalanceAfter == ownerBalanceBefore);

        if (fundsTransferred) {
            console2.log("Vulnerability Exists: Owner drained contract funds");
            console2.log("--- Test Result ---");
            console2.log("Critical: Owner successfully selfdestructed contract and transferred funds");
        } else if (noChange) {
            console2.log("Vulnerability not Exist: Kill operation failed");
            console2.log("--- Test Result ---");
            console2.log("No state change occurred after kill attempt");
        } else {
            console2.log("Vulnerability Partially Exists: Unexpected state modification");
            console2.log("--- Test Result ---");
            console2.log("Unexpected balance changes after kill attempt");
        }

        // Final verdict declaration (exactly one final line)
        assertTrue(fundsTransferred);
        console2.log("Vulnerability Exists: Owner can trigger selfdestruct to take funds"); 
    }
}