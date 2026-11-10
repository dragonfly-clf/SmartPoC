// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZeusPet.sol";

contract ReentrantMarketingWallet {
    ZeusPet public token;
    address public attacker;
    uint256 public reenterAmount;
    
    constructor(ZeusPet _token) {
        token = _token;
    }
    
    function setAttackDetails(address _attacker, uint256 _amount) external {
        attacker = _attacker;
        reenterAmount = _amount;
    }
    
    function startAttack() external {
        token.transfer(attacker, reenterAmount);
    }
}

contract ZeusPetAtomicityTest is Test {
    ZeusPet public token;
    ReentrantMarketingWallet public maliciousWallet;
    
    address public constant BURN_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    address public owner;
    address public attacker = address(0xBAD);
    address public victim = address(0xABC);
    
    function setUp() public {
        owner = address(this);
        
        // Deploy token with custom fees
        token = new ZeusPet(
            10,  // 10% marketing fee
            0,   // 0% burn fee
            address(0) // Temp wallet, update later
        );
        
        // Transfer ownership to test contract
        vm.startPrank(token.owner());
        token.transferOwnership(owner);
        vm.stopPrank();
        
        // Update roles
        vm.startPrank(owner);
        maliciousWallet = new ReentrantMarketingWallet(token);
        maliciousWallet.setAttackDetails(attacker, 10 ether);
        token.setMarketingWallet(address(maliciousWallet));
        vm.stopPrank();
        
        // Fund attacker
        token.transfer(attacker, 1000 ether);
    }
    
    function test_FeeProcessingVulnerability() public {
        vm.startPrank(attacker);
        token.approve(address(maliciousWallet), 1000 ether);
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 attackerBalBefore = token.balanceOf(attacker);
        uint256 victimBalBefore = token.balanceOf(victim);
        uint256 maliciousBalBefore = token.balanceOf(address(maliciousWallet));
        uint256 burnBalBefore = token.balanceOf(BURN_ADDRESS);
        
        console2.log("Attacker balance before:", attackerBalBefore);
        console2.log("Victim balance before:", victimBalBefore);
        console2.log("Marketing balance before:", maliciousBalBefore);
        console2.log("Burn address balance before:", burnBalBefore);
        
        // Expected changes if fees are applied correctly
        uint256 expectedAttackerLoss = 100 ether;
        uint256 expectedVictimGain = 90 ether; // 100 - 10% fee
        uint256 expectedMarketingGain = 10 ether;
        
        console2.log("\n--- Executing Attack Trigger ---");
        token.transfer(victim, 100 ether);
        console2.log("--- AFTER-Trigger State ---");
        
        uint256 attackerBalAfter = token.balanceOf(attacker);
        uint256 victimBalAfter = token.balanceOf(victim);
        uint256 maliciousBalAfter = token.balanceOf(address(maliciousWallet));
        uint256 burnBalAfter = token.balanceOf(BURN_ADDRESS);
        
        console2.log("Attacker balance after:", attackerBalAfter);
        console2.log("Victim balance after:", victimBalAfter);
        console2.log("Marketing balance after:", maliciousBalAfter);
        console2.log("Burn address balance after:", burnBalAfter);
        
        // Actual state changes
        uint256 actualAttackerLoss = attackerBalBefore - attackerBalAfter;
        uint256 actualVictimGain = victimBalAfter - victimBalBefore;
        uint256 actualMarketingGain = maliciousBalAfter - maliciousBalBefore;
        uint256 actualBurnChange = burnBalAfter - burnBalBefore;
        
        console2.log("\n--- Differential Verification ---");
        console2.log("Expected attacker loss: %d", expectedAttackerLoss);
        console2.log("Actual attacker loss: %d", actualAttackerLoss);
        console2.log("Expected victim gain: %d", expectedVictimGain);
        console2.log("Actual victim gain: %d", actualVictimGain);
        console2.log("Expected marketing gain: %d", expectedMarketingGain);
        console2.log("Actual marketing gain: %d", actualMarketingGain);
        console2.log("Burn change: %d", actualBurnChange);
        
        // Additional requirement: Check if marketing wallet received fee
        assertEq(
            maliciousBalAfter,
            maliciousBalBefore + 10 ether, // 10% of 100 ether
            "Marketing wallet did not receive fee"
        );
        
        // Final vulnerability assessment
        bool vulnerabilityExists = false;
        string memory reason = "";
        
        if(actualAttackerLoss != expectedAttackerLoss) {
            vulnerabilityExists = true;
            reason = "Unexpected attacker balance change";
        } else if(actualVictimGain != expectedVictimGain) {
            vulnerabilityExists = true;
            reason = "Unexpected victim balance change";
        } else if(actualMarketingGain != expectedMarketingGain) {
            vulnerabilityExists = true;
            reason = "Unexpected marketing wallet balance change";
        } else if(actualBurnChange != 0) {
            vulnerabilityExists = true;
            reason = "Unexpected burn address balance change";
        }
        
        if(vulnerabilityExists) {
            console2.log("Vulnerability exists: %s", reason);
        } else {
            console2.log("Vulnerability not exists: All balances changed as expected");
        }
        
        // Final verdict (must exactly one output as per requirements)
        if(vulnerabilityExists) {
            console2.log("Vulnerability Exists: Atomicity violation detected via state inconsistency");
        } else {
            console2.log("Vulnerability not Exist: No state inconsistency detected");
        }
    }
}