// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x7a4349a749e59a5736efb7826ee3496a2dfd5489.sol";

contract WhaleGiveaway1Test is Test {
    WhaleGiveaway1 giveaway;
    address owner = address(0x1);

    function setUp() public {
        vm.prank(owner);
        giveaway = new WhaleGiveaway1();
        vm.deal(owner, 10 ether); // Fund owner with ETH
    }

    function testUncheckedCall() public {
        // Create a contract that will reject ETH transfers
        EthRejector rejector = new EthRejector();
        
        console2.log("--- BEFORE-Trigger Balances ---");
        // Record initial balances for differential comparison
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialRejectorBalance = address(rejector).balance;
        uint256 initialGiveawayBalance = address(giveaway).balance;
        
        console2.log("Owner ETH Balance (before):", initialOwnerBalance);
        console2.log("Rejector ETH Balance (before):", initialRejectorBalance);
        console2.log("WhaleGiveaway ETH Balance (before):", initialGiveawayBalance);

        console2.log("--- Trigger Command Call ---");
        // Simulate owner calling Command() with ETH
        vm.prank(owner);
        giveaway.Command{value: 1 ether}(
            address(rejector),
            abi.encodeWithSignature("doNothing()")
        );
        console2.log("Triggered vulnerable Command call with 1 ETH");

        console2.log("--- AFTER-Trigger Balances ---");
        // Capture post-attack balances
        uint256 finalOwnerBalance = owner.balance;
        uint256 finalRejectorBalance = address(rejector).balance;
        uint256 finalGiveawayBalance = address(giveaway).balance;
        
        console2.log("Owner ETH Balance (after):", finalOwnerBalance);
        console2.log("Rejector ETH Balance (after):", finalRejectorBalance);
        console2.log("WhaleGiveaway ETH Balance (after):", finalGiveawayBalance);

        // Calculate balance changes
        uint256 ownerLoss = initialOwnerBalance - finalOwnerBalance;
        uint256 rejectorGain = finalRejectorBalance - initialRejectorBalance;
        uint256 giveawayGain = finalGiveawayBalance - initialGiveawayBalance;
        
        console2.log("Owner ETH Loss:", ownerLoss);
        console2.log("Rejector ETH Gain:", rejectorGain);
        console2.log("WhaleGiveaway ETH Gain:", giveawayGain);

        // Define vulnerability conditions
        bool condition1 = ownerLoss == 1 ether; // Owner lost exactly 1 ETH
        bool condition2 = rejectorGain == 0; // Rejector got nothing
        bool condition3 = giveawayGain == 1 ether; // Giveaway got full amount
        bool vulnerabilitySuccess = condition1 && condition2 && condition3;
        
        // Vulnerability exists if all conditions met
        if (vulnerabilitySuccess) {
            console2.log("Vulnerability Exists: The transaction succeeded despite the inner call reverting, and 1 ETH was transferred to WhaleGiveaway");
        } else {
            console2.log("Vulnerability not Exist: Balance changes do not match exploitation pattern");
        }
        
        // Make the test fail if vulnerability doesn't manifest as expected
        assertEq(finalRejectorBalance, 0, "ETH should not have been transferred to rejector");
        assertEq(giveawayGain, 1 ether, "Giveaway should have received 1 ETH");
    }
}

contract EthRejector {
    function doNothing() external payable {
        // This contract will reject ETH transfers
        revert("ETH not accepted");
    }
}