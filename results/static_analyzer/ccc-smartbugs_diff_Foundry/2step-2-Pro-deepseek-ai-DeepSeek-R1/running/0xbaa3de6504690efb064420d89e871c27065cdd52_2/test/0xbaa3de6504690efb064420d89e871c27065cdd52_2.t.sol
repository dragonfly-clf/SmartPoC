// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract OwnerContractNoReceive {
    VaultProxy public vault;
    
    function deployVault() public {
        vault = new VaultProxy();
    }
    
    function depositToVault() public payable {
        vault.deposit{value: msg.value}();
    }
    
    function withdraw(uint256 amount) public {
        vault.withdraw(amount);
    }
}

contract TestWithdrawDoS is Test {
    OwnerContractNoReceive ownerContract;
    VaultProxy vault;

    function setUp() public {
        ownerContract = new OwnerContractNoReceive();
        vm.deal(address(ownerContract), 1 ether);
        
        vm.startPrank(address(ownerContract));
        ownerContract.deployVault();
        vault = ownerContract.vault();
        ownerContract.depositToVault{value: 1 ether}();
        vm.stopPrank();
    }

    function test_WithdrawalFailsWhenOwnerCannotReceiveEth() public {
        assertEq(address(vault).balance, 1 ether, "Vault balance incorrect");
        
        console2.log("--- BEFORE-Trigger Withdrawal ---");
        uint256 vaultBalanceBefore = address(vault).balance;
        uint256 ownerBalanceBefore = address(ownerContract).balance;
        uint256 depositInVaultBefore = vault.Deposits(address(ownerContract));
        uint256 totalDepositsBefore = vault.totalDeposits();
        
        console2.log("Vault balance (before): %s", vaultBalanceBefore);
        console2.log("Owner balance (before): %s", ownerBalanceBefore);
        console2.log("Owner deposit in Vault (before): %s", depositInVaultBefore);
        console2.log("Total deposits (before): %s", totalDepositsBefore);
        
        console2.log("--- Trigger Withdrawal ---");
        vm.prank(address(ownerContract));
        vm.expectRevert();
        ownerContract.withdraw(1 ether);
        
        console2.log("--- AFTER-Trigger Withdrawal ---");
        uint256 vaultBalanceAfter = address(vault).balance;
        uint256 ownerBalanceAfter = address(ownerContract).balance;
        uint256 depositInVaultAfter = vault.Deposits(address(ownerContract));
        uint256 totalDepositsAfter = vault.totalDeposits();
        
        console2.log("Vault balance (after): %s", vaultBalanceAfter);
        console2.log("Owner balance (after): %s", ownerBalanceAfter);
        console2.log("Owner deposit in Vault (after): %s", depositInVaultAfter);
        console2.log("Total deposits (after): %s", totalDepositsAfter);
        
        bool unchanged = vaultBalanceBefore == vaultBalanceAfter &&
                         ownerBalanceBefore == ownerBalanceAfter &&
                         depositInVaultBefore == depositInVaultAfter &&
                         totalDepositsBefore == totalDepositsAfter;
        
        console2.log("State unchanged? %s", unchanged ? "YES" : "NO");
        console2.log("Vulnerability Status: %s", unchanged ? "Vulnerability Exists" : "Vulnerability not Exist");
        
        assertEq(address(vault).balance, 1 ether, "Funds were withdrawn");
        assertEq(
            address(ownerContract).balance, 
            0, 
            "Owner received ETH despite not having fallback"
        );
    }
}