// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/roulette.sol";

contract RouletteTest is Test {
    Roulette public roulette;
    address owner = makeAddr("owner");

    function setUp() public {
        // Fund owner for gas costs
        vm.deal(owner, 1 ether);
        
        vm.startPrank(owner);
        roulette = new Roulette{value: 0}();
        vm.stopPrank();
    }

    function test_WithdrawOwnerShareWithInsufficientBalance_DoesNotRevert() public {
        // Fund contract with 9 wei (less than 10 wei required for non-zero owner share)
        uint256 lowBalance = 9;
        vm.deal(address(roulette), lowBalance);

        // Pre-trigger state snapshot
        console.log("\n--- BEFORE-Trigger withdrawOwnerShare ---");
        uint256 contractBalancePre = address(roulette).balance;
        uint256 ownerBalancePre = owner.balance;
        console.log("Contract balance:", contractBalancePre, "wei");
        console.log("Owner balance:", ownerBalancePre, "wei");

        console.log("\n--- Trigger withdrawOwnerShare ---");
        // Verify function doesn't revert when owner calls with low balance
        vm.prank(owner);
        roulette.withdrawOwnerShare();

        // Post-trigger state snapshot
        console.log("\n--- AFTER-Trigger withdrawOwnerShare ---");
        uint256 contractBalancePost = address(roulette).balance;
        uint256 ownerBalancePost = owner.balance;
        console.log("Contract balance:", contractBalancePost, "wei");
        console.log("Owner balance:", ownerBalancePost, "wei");

        // State comparison
        console.log("\n--- DIFF RESULT ---");
        bool contractBalanceUnchanged = (contractBalancePost == contractBalancePre);
        bool ownerBalanceNotIncreased = (ownerBalancePost <= ownerBalancePre);
        console.log("Contract balance unchanged:", contractBalanceUnchanged);
        console.log("Owner balance did not increase:", ownerBalanceNotIncreased);

        // Render vulnerability verdict
        if (!contractBalanceUnchanged) {
            console.log("\nVulnerability Exists: Contract balance changed unexpectedly");
        } else if (!ownerBalanceNotIncreased) {
            console.log("\nVulnerability Exists: Owner received unexpected ETH");
        } else {
            console.log("\nVulnerability not Exist: State remains stable (contract balance unchanged, owner didn't receive ETH)");
        }

        // Original assertions remain
        assertEq(contractBalancePost, lowBalance, "Contract balance should remain unchanged");
    }
}