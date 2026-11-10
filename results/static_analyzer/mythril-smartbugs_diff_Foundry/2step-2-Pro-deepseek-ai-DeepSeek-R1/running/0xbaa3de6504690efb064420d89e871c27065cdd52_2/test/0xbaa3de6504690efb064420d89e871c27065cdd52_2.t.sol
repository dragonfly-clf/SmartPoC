// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract VaultProxyTest is Test {
    VaultProxy vault;
    address owner = address(0xBAA3);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);
        vault = new VaultProxy{value: 1 ether}();
        vm.stopPrank();
    }

    function testWithdrawUnderflow() public {
        vm.startPrank(owner);
        
        // Record pre-trigger state
        uint256 contractBalanceBefore = address(vault).balance;
        uint256 ownerBalanceBefore = owner.balance;
        uint256 depositorBalanceBefore = vault.Deposits(owner);
        uint256 totalDepositsBefore = vault.totalDeposits();

        console.log("--- BEFORE-Trigger State ---");
        console.log("Contract ETH balance:", contractBalanceBefore);
        console.log("Owner ETH balance:", ownerBalanceBefore);
        console.log("Owner deposit (Vault):", depositorBalanceBefore);
        console.log("Total deposits (Vault):", totalDepositsBefore);
        console.log("");

        // Attempt withdrawal exceeding contract balance
        uint256 excessAmount = contractBalanceBefore + 1;
        assertTrue(excessAmount > contractBalanceBefore, "Excess amount should exceed contract balance");
        
        console.log("--- Trigger Action ---");
        console.log("Calling vault.withdraw(%d) with owner", excessAmount);
        vault.withdraw(excessAmount);

        // Record post-trigger state
        uint256 contractBalanceAfter = address(vault).balance;
        uint256 ownerBalanceAfter = owner.balance;
        uint256 depositorBalanceAfter = vault.Deposits(owner);
        uint256 totalDepositsAfter = vault.totalDeposits();

        console.log("");
        console.log("--- AFTER-Trigger State ---");
        console.log("Contract ETH balance:", contractBalanceAfter);
        console.log("Owner ETH balance:", ownerBalanceAfter);
        console.log("Owner deposit (Vault):", depositorBalanceAfter);
        console.log("Total deposits (Vault):", totalDepositsAfter);
        console.log("");

        // Compare state changes
        console.log("--- State Comparison Results ---");
        bool allStatesUnchanged = true;
        
        bool contractBalanceSame = (contractBalanceBefore == contractBalanceAfter);
        console.log("Contract balance same:", contractBalanceSame ? "YES" : "NO");
        allStatesUnchanged = allStatesUnchanged && contractBalanceSame;

        bool ownerBalanceSame = (ownerBalanceBefore == ownerBalanceAfter);
        console.log("Owner ETH balance same:", ownerBalanceSame ? "YES" : "NO");
        allStatesUnchanged = allStatesUnchanged && ownerBalanceSame;

        bool depositRecordSame = (depositorBalanceBefore == depositorBalanceAfter);
        console.log("Deposit record same:", depositRecordSame ? "YES" : "NO");
        allStatesUnchanged = allStatesUnchanged && depositRecordSame;

        bool totalDepositsSame = (totalDepositsBefore == totalDepositsAfter);
        console.log("Total deposits same:", totalDepositsSame ? "YES" : "NO");
        allStatesUnchanged = allStatesUnchanged && totalDepositsSame;

        // Final vulnerability verdict
        console.log("");
        if (allStatesUnchanged) {
            console.log("Vulnerability Exists: All state unchanged after withdrawal call - Successful underflow exploitation");
        } else {
            console.log("Vulnerability not Exist: State changed - Exploitation failed");
        }
        
        vm.stopPrank();
    }
}