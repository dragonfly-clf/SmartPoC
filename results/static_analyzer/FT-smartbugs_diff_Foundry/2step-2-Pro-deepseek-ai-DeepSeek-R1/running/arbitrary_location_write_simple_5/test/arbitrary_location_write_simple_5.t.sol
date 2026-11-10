// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/arbitrary_location_write_simple.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address owner = makeAddr("owner");
    address nonOwner = makeAddr("nonOwner");
    address public beneficiary;
    uint256 public initialWalletBalance = 1 ether;

    function setUp() public {
        vm.prank(owner);
        wallet = new Wallet();
    }

    function test_DestroyByOwner() public {
        // Fund the contract
        vm.deal(address(wallet), initialWalletBalance);
        
        // Differential verification start
        console2.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(wallet).balance;
        uint256 ownerBalanceBefore = owner.balance;
        console2.log("Contract Balance (wei):", contractBalanceBefore);
        console2.log("Owner Balance (wei):", ownerBalanceBefore);
        
        console2.log("--- Trigger Operation: Destroy ---");
        vm.prank(owner);
        wallet.Destroy();
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(wallet).balance;
        uint256 ownerBalanceAfter = owner.balance;
        console2.log("Contract Balance (wei):", contractBalanceAfter);
        console2.log("Owner Balance (wei):", ownerBalanceAfter);
        
        bool contractBalanceCleared = contractBalanceAfter == 0;
        bool ownerReceivedFunds = ownerBalanceAfter == ownerBalanceBefore + initialWalletBalance;
        bool vulnerabilityExists = contractBalanceCleared && ownerReceivedFunds;
        
        if (vulnerabilityExists) {
            console2.log("Verdict: Vulnerability Exists: Destroy function successfully transferred contract funds to owner");
        } else {
            console2.log("Verdict: Vulnerability not Exist: Contract destruction didn't transfer funds correctly");
        }
        
        assertEq(contractBalanceAfter, 0, "Contract should have 0 balance");
        assertEq(ownerBalanceAfter, ownerBalanceBefore + initialWalletBalance, "Owner should receive the funds");
    }

    function test_DestroyByNonOwnerReverts() public {
        // Fund the contract
        vm.deal(address(wallet), initialWalletBalance);

        // Non-owner tries to destroy
        vm.prank(nonOwner);
        vm.expectRevert();
        wallet.Destroy();

        // Contract balance should remain intact
        assertEq(address(wallet).balance, initialWalletBalance, "Contract balance should remain");
    }

    function test_DestroyLosesContractStateAndFunds() public {
        // Optional: Show that after destruction, contract is unusable
        test_DestroyByOwner();
        
        // Try to interact with destroyed contract (should fail)
        vm.prank(owner);
        vm.expectRevert();
        wallet.UpdateBonusCodeAt(0, 100);
    }
}