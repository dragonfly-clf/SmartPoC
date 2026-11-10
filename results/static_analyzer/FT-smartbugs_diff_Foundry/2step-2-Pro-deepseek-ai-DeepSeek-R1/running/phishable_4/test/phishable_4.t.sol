// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/phishable.sol";

contract PhishableTest is Test {
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    Phishable public phishableContract;

    function setUp() public {
        phishableContract = new Phishable(owner);
    }

    function test_anyoneCanDeposit() public {
        console2.log("--- BEFORE-Trigger Deposit ---");
        // Query initial state
        uint256 attackerBalanceBefore = phishableContract.getUserBalance(attacker);
        uint256 contractBalanceBefore = address(phishableContract).balance;
        console2.log("Attacker balance before:", attackerBalanceBefore);
        console2.log("Contract ETH balance before:", contractBalanceBefore);

        console2.log("--- Trigger Deposit ---");
        // Deposit from the attacker address
        hoax(attacker, 1 ether);
        (bool success,) = address(phishableContract).call{value: 1 ether}("");
        require(success, "Deposit failed");

        console2.log("--- AFTER-Trigger Deposit ---");
        // Query state after deposit
        uint256 attackerBalanceAfter = phishableContract.getUserBalance(attacker);
        uint256 contractBalanceAfter = address(phishableContract).balance;
        console2.log("Attacker balance after:", attackerBalanceAfter);
        console2.log("Contract ETH balance after:", contractBalanceAfter);

        // Verify balance differences
        uint256 userDifference = attackerBalanceAfter - attackerBalanceBefore;
        uint256 contractDifference = contractBalanceAfter - contractBalanceBefore;
        console2.log("User balance difference:", userDifference);
        console2.log("Contract balance difference:", contractDifference);
        
        // Determine vulnerability existence
        if (userDifference == 1 ether && contractDifference == 1 ether) {
            console2.log("Comparison verdict: State changed as expected - Vulnerability Exists");
            console2.log("Vulnerability Exists: Attacker successfully deposited and balance updated");
        } else {
            console2.log("Comparison verdict: State change mismatch - Vulnerability not Exist");
            console2.log("Vulnerability not Exist: Balance changes did not match deposit amount");
        }
        
        // Original test assertions remain intact
        uint256 attackerBalance = phishableContract.getUserBalance(attacker);
        assertEq(attackerBalance, 1 ether, "Attacker balance should be 1 ether");
        assertEq(address(phishableContract).balance, 1 ether, "Contract ETH balance should be 1 ether");
    }
}