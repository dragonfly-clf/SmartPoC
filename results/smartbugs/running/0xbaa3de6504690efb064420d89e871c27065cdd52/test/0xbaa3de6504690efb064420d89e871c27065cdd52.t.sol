// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract VaultProxyTest is Test {
    VaultProxy vault;
    address owner = address(0x1);
    
    // Target contract that will fail when receiving ETH
    ContractThatRejectsETH rejectETHContract;
    
    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        vault = new VaultProxy{value: 1 ether}();
        
        // Deploy a contract that rejects ETH transfers
        rejectETHContract = new ContractThatRejectsETH();
    }
    
    function testUncheckedLowLevelCall() public {
        // Record initial state before trigger
        uint256 preTriggerVaultBalance = vault.getTotalBalance();
        uint256 preTriggerTargetBalance = address(rejectETHContract).balance;
        
        console.log("--- BEFORE-Trigger Balances ---");
        console.log("VaultProxy balance: %d", preTriggerVaultBalance);
        console.log("Target contract balance: %d", preTriggerTargetBalance);
        console.log("");
        
        // Prepare malicious call data
        bytes memory maliciousData = abi.encodeWithSignature("nonExistentFunction()");
        
        console.log("--- Trigger Proxy Call ---");
        // Attempt to proxy ETH to a contract that will reject it
        vm.prank(owner);
        vault.proxy{value: 1 ether}(address(rejectETHContract), maliciousData);
        
        // Record state after trigger
        uint256 postTriggerVaultBalance = vault.getTotalBalance();
        uint256 postTriggerTargetBalance = address(rejectETHContract).balance;
        
        console.log("--- AFTER-Trigger Balances ---");
        console.log("VaultProxy balance: %d", postTriggerVaultBalance);
        console.log("Target contract balance: %d", postTriggerTargetBalance);
        console.log("");

        // Calculate balance changes
        uint256 vaultDiff = postTriggerVaultBalance - preTriggerVaultBalance;
        uint256 targetDiff = postTriggerTargetBalance - preTriggerTargetBalance;
        
        console.log("--- Balance Changes ---");
        console.log("VaultProxy balance increase: %d", vaultDiff);
        console.log("Target contract balance increase: %d", targetDiff);
        
        // Final vulnerability verification
        bool vulnerabilityExists = 
            vaultDiff == 1 ether &&
            targetDiff == 0 &&
            postTriggerVaultBalance == 2 ether &&
            postTriggerTargetBalance == 0;

        console.log(vulnerabilityExists 
            ? "Vulnerability Exists: ETH was accepted but not forwarded, leaving funds stuck in vault" 
            : "Vulnerability not Exist: ETH transfer behavior changed unexpectedly"
        );
    }
}

contract ContractThatRejectsETH {
    // This contract will reject any ETH transfers
    receive() external payable {
        revert("This contract rejects ETH");
    }
}