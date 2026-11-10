// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol"; // Correct import for logging
import "../src/0x806a6bd219f162442d992bdc4ee6eba1f2c5a707.sol";

contract UnsafeCallTest is Test {
    Pie public vault;
    GasConsumer public attacker;
    address owner = makeAddr("owner");
    uint256 constant VALUE = 1 ether;

    function setUp() public {
        vm.deal(owner, VALUE);
        vm.prank(owner);
        vault = new Pie();
    }

    function testCallForwardsDangerousGasAmount() public {
        console2.log("--- BEFORE-Trigger STATES ---");
        uint256 vaultBalanceBefore = address(vault).balance;
        uint256 attackerGasUsedBefore = 0; // Attacker not deployed = 0
        console2.log("Vault ETH balance (before):", vaultBalanceBefore);
        console2.log("Attacker gasUsed (before):", attackerGasUsedBefore);

        // Deploy attacker contract
        attacker = new GasConsumer();
        
        console2.log("--- PRE-Trigger STATES ---");
        vaultBalanceBefore = address(vault).balance;
        attackerGasUsedBefore = attacker.gasUsed(); // Should be 0 here
        console2.log("Re-check Vault balance (before):", vaultBalanceBefore);
        console2.log("Re-check Attacker gasUsed (before):", attackerGasUsedBefore);

        console2.log("--- TRIGGER Operation: Command call ---");
        bytes memory payload = abi.encodeWithSelector(
            GasConsumer.consumeGas.selector
        );

        // Execute vulnerable Command
        vm.prank(owner);
        vault.Command{value: VALUE}(address(attacker), payload);
        
        console2.log("--- AFTER-Trigger STATES ---");
        uint256 vaultBalanceAfter = address(vault).balance;
        uint256 attackerGasUsedAfter = attacker.gasUsed();
        console2.log("Vault ETH balance (after):", vaultBalanceAfter);
        console2.log("Attacker gasUsed (after):", attackerGasUsedAfter);

        // Differential analysis
        console2.log("[DIFFERENTIAL COMPARISON]");
        console2.log("GasUsed delta:", attackerGasUsedAfter);
        console2.log("Balance change:", vaultBalanceBefore - vaultBalanceAfter);
        
        // Vulnerability verification
        bool vulnerabilityExists = attackerGasUsedAfter > 2300;
        if (vulnerabilityExists) {
            console2.log("Verdict: Vulnerability Exists - Attacker consumed %s gas (>2300)", attackerGasUsedAfter);
            console2.log("Final: Vulnerability Exists: Unsafe gas forwarding allows re-entrancy");
        } else {
            console2.log("Verdict: Vulnerability not Exist - Attacker consumed only %s gas (<=2300)", attackerGasUsedAfter);
            console2.log("Final: Vulnerability not Exist: Gas usage within safe limits");
        }

        // Assertion from original test maintained
        assertGt(attackerGasUsedAfter, 2300, "Vault forwarded sufficient gas for re-entrancy");
    }
}

contract GasConsumer {
    uint256 public startGas;
    uint256 public gasUsed;
    
    function consumeGas() external payable {
        startGas = gasleft();
        
        // Perform gas-intensive operation
        for(uint i; i < 100; i++) {
            assembly {
                let x := mload(0)
            }
        }
        
        gasUsed = startGas - gasleft();
    }
}