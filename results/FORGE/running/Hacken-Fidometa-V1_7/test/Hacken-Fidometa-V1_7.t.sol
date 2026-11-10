// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidometaFeesTest is Test {
    Fidometa token;
    address owner;
    address alice = address(0xA11c3);
    address bob = address(0xB0B);
    uint256 initialSupply;

    function setUp() public {
        owner = address(this);
        token = new Fidometa();
        initialSupply = token.balanceOf(owner);
        
        // Transfer tokens to test user (owner is excluded from fees)
        token.transfer(alice, initialSupply / 2);
    }

    function testFeeOverflowRevertsTransfers() public {
        uint256 MAX_PERCENTAGE = 100 * 10 ** token.decimals();
        uint256 transferAmount = 100 * 10 ** token.decimals(); // 100 tokens
        
        // --- PRE-TRIGGER TRANSFER (BASELINE) ---
        console.log("--- PRE-TRIGGER TRANSFER (BASELINE) ---");
        uint256 alicePreNormal = token.balanceOf(alice);
        uint256 bobPreNormal = token.balanceOf(bob);
        console.log("[STATE] Alice initial balance:", alicePreNormal);
        console.log("[STATE] Bob initial balance:", bobPreNormal);
        
        // Execute baseline transfer (with normal fees)
        vm.prank(alice);
        token.transfer(bob, transferAmount);
        
        uint256 alicePostNormal = token.balanceOf(alice);
        uint256 bobPostNormal = token.balanceOf(bob);
        console.log("[STATE] Alice after normal transfer:", alicePostNormal);
        console.log("[STATE] Bob after normal transfer:", bobPostNormal);
        // Corrected fee calculation: Actual fees = (Alice reduction) - (Bob gain)
        uint256 actualFee = (alicePreNormal - alicePostNormal) - (bobPostNormal - bobPreNormal);
        console.log("[DIFF] Actual fees charged:", actualFee);
        console.log("");
        
        // --- TRIGGER: SET MAX FEES ---
        console.log("--- TRIGGER: SET MAX FEES ---");
        // Set all fee percentages to maximum allowed
        vm.startPrank(owner);
        token.setCommunityCharge(MAX_PERCENTAGE);
        token.setEcoSysFee(MAX_PERCENTAGE);
        token.setSurcharge1(MAX_PERCENTAGE);
        token.setSurcharge2(MAX_PERCENTAGE);
        token.setSurcharge3(MAX_PERCENTAGE);
        vm.stopPrank();
        console.log("All fees set to maximum values (100%)");
        console.log("");
        
        // --- POST-TRIGGER TRANSFER ATTEMPT ---
        console.log("--- POST-TRIGGER TRANSFER ATTEMPT ---");
        uint256 alicePreAttempt = token.balanceOf(alice);
        uint256 bobPreAttempt = token.balanceOf(bob);
        console.log("[STATE] Alice pre-attempt balance:", alicePreAttempt);
        console.log("[STATE] Bob pre-attempt balance:", bobPreAttempt);
        
        // Attempt transfer between non-excluded accounts (with max fees)
        vm.prank(alice);
        vm.expectRevert(); // Expect revert due to arithmetic overflow
        token.transfer(bob, transferAmount);
        
        uint256 alicePostAttempt = token.balanceOf(alice);
        uint256 bobPostAttempt = token.balanceOf(bob);
        console.log("[STATE] Alice post-attempt balance:", alicePostAttempt);
        console.log("[STATE] Bob post-attempt balance:", bobPostAttempt);
        
        // --- DIFFERENTIAL ANALYSIS ---
        console.log("");
        console.log("--- DIFFERENTIAL ANALYSIS ---");
        bool transferReverted = (alicePostAttempt == alicePreAttempt) && 
                                (bobPostAttempt == bobPreAttempt);
        bool vulnerabilityExists = transferReverted;
        
        if (vulnerabilityExists) {
            console.log("[VERDICT] Second transfer reverted with unchanged balances -> Fee overflow vulnerability exists");
            console.log("Vulnerability Exists: Transfer reverts when fees are set to maximum due to arithmetic overflow.");
        }
        else {
            console.log("[VERDICT] Balances changed unexpectedly -> Transfer executed despite max fees");
            console.log("Vulnerability not Exist: Fee settings did not break transfers.");
        }
    }
}