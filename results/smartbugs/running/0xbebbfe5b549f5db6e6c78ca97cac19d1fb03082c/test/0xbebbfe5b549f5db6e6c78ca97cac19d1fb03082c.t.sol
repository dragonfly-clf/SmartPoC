// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbebbfe5b549f5db6e6c78ca97cac19d1fb03082c.sol";

contract VaultProxyTest is Test {
    VaultProxy vault;
    address owner = address(0x1);
    
    // Mock target contract that will fail when receiving ETH
    address failingTarget;

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        vault = new VaultProxy{value: 5 ether}();
        
        // Create a failing target (contract without payable fallback)
        failingTarget = address(new NonPayableContract());
    }

    function testUncheckedLowLevelCall() public {
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 initialVaultBalance = vault.getContractBalance();
        uint256 initialTargetBalance = failingTarget.balance;
        console.log("Vault Balance Before:", initialVaultBalance);
        console.log("Target Balance Before:", initialTargetBalance);

        console.log("--- Trigger: Call proxy with value ---");
        // Prepare some dummy data for the call
        bytes memory data = abi.encodeWithSignature("nonExistentFunction()");
        
        // Attempt to proxy ETH to a non-payable contract
        vm.prank(owner);
        vault.proxy{value: 1 ether}(failingTarget, data);
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 newVaultBalance = vault.getContractBalance();
        uint256 newTargetBalance = failingTarget.balance;
        console.log("Vault Balance After:", newVaultBalance);
        console.log("Target Balance After:", newTargetBalance);
        
        // Calculate balance changes
        uint256 vaultDiff = newVaultBalance - initialVaultBalance;
        uint256 targetDiff = newTargetBalance - initialTargetBalance;
        console.log("Vault Balance Change:", vaultDiff);
        console.log("Target Balance Change:", targetDiff);
        
        // Verify vulnerability conditions
        bool fundsNotTransferred = (vaultDiff == 1 ether) && (targetDiff == 0);
        bool txDidNotRevert = true; // Function call succeeded without revert
        
        if (fundsNotTransferred && txDidNotRevert) {
            console.log("Vulnerability Exists: ETH transfer failed silently without reverting, funds returned to vault");
        } else {
            console.log("Vulnerability not Exist: Funds were either transferred or transaction reverted");
        }
    }
}

// Helper contract that cannot receive ETH
contract NonPayableContract {
    function nonExistentFunction() external pure returns (bool) {
        return true;
    }
}