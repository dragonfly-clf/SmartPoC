// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MyBond.sol";

contract MyBondTest_OperatorMinting is Test {
    MyBond token;
    address operator;
    address attacker = address(0xBAD);

    function setUp() public {
        token = new MyBond();
        operator = token.operator();
    }

    function testOperatorCanMintUnlimitedTokens() public {
        // Pre-trigger state snapshot
        console.log("--- BEFORE-Trigger State Snapshot ---");
        uint256 initialTotalSupply = token.totalSupply();
        uint256 initialAttackerBalance = token.balanceOf(attacker);
        console.log("Initial Total Supply: %s", initialTotalSupply);
        console.log("Attacker Balance Before: %s", initialAttackerBalance);
        
        // Trigger operation
        console.log("--- TRIGGER: Operator minting to attacker ---");
        vm.prank(operator);
        bool mintSuccess = token.mint(attacker, 1_000_000 ether);
        
        // Post-trigger state snapshot
        console.log("--- AFTER-Trigger State Snapshot ---");
        uint256 finalTotalSupply = token.totalSupply();
        uint256 finalAttackerBalance = token.balanceOf(attacker);
        console.log("Final Total Supply: %s", finalTotalSupply);
        console.log("Attacker Balance After: %s", finalAttackerBalance);
        
        // State verification and vulnerability check
        console.log("--- Differential State Verification ---");
        uint256 expectedSupplyChange = 1_000_000 ether;
        uint256 actualSupplyChange = finalTotalSupply - initialTotalSupply;
        uint256 actualBalanceChange = finalAttackerBalance - initialAttackerBalance;
        
        console.log("Expected Supply Increase: %s", expectedSupplyChange);
        console.log("Actual Supply Increase: %s", actualSupplyChange);
        console.log("Expected Balance Increase: %s", expectedSupplyChange);
        console.log("Actual Balance Increase: %s", actualBalanceChange);
        
        // Vulnerability existence determination
        bool canMintUnlimited = mintSuccess &&
            actualSupplyChange == expectedSupplyChange &&
            actualBalanceChange == expectedSupplyChange;

        string memory verdictOutput;
        if (canMintUnlimited) {
            verdictOutput = "Vulnerability Exists: Operator can mint tokens without restrictions";
        } else {
            verdictOutput = "Vulnerability not Exist: Operator could not mint arbitrary tokens";
        }
        // Print final verdict as one-line output
        console.log(verdictOutput);
        
        // Fail test if vulnerability doesn't exist
        require(canMintUnlimited, verdictOutput);
    }
}