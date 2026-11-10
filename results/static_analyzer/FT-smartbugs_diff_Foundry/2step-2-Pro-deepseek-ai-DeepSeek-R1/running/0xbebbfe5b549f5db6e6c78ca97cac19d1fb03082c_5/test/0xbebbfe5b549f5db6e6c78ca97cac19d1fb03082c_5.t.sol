// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbebbfe5b549f5db6e6c78ca97cac19d1fb03082c.sol";

contract VaultProxyDepositTest is Test {
    VaultProxy public vault;
    address public nonOwner = makeAddr("nonOwner");

    function setUp() public {
        vault = new VaultProxy{value: 0}();
        vm.deal(nonOwner, 1 ether);
    }

    function test_NonOwnerCanDeposit() public {
        uint256 depositAmount = 0.1 ether;
        
        // Pre-trigger state snapshot
        console2.log("--- BEFORE-Trigger deposit ---");
        uint256 initialContractBalance = vault.getContractBalance();
        uint256 initialNonOwnerDeposit = vault.Deposits(nonOwner);
        console2.log("Contract balance (wei):", initialContractBalance);
        console2.log("Non-Owner deposit record (wei):", initialNonOwnerDeposit);

        console2.log("--- Trigger deposit ---");
        console2.log("Non-Owner depositing 0.1 ether...");
        
        // Execute deposit operation with state change observation
        bool success;
        vm.startPrank(nonOwner);
        (success, ) = address(vault).call{value: depositAmount}(
            abi.encodeWithSelector(vault.deposit.selector)
        );
        vm.stopPrank();

        // Post-trigger state snapshot
        console2.log("--- AFTER-Trigger deposit ---");
        uint256 newContractBalance = vault.getContractBalance();
        uint256 newNonOwnerDeposit = vault.Deposits(nonOwner);
        console2.log("Deposit call success:", success);
        console2.log("Contract balance (wei):", newContractBalance);
        console2.log("Non-Owner deposit record (wei):", newNonOwnerDeposit);

        // Final vulnerability verdict
        if (success) {
            console2.log("Vulnerability Exists: Non-Owner deposit function call succeeded");
        } else {
            console2.log("Vulnerability not Exist: Non-Owner deposit function call reverted");
        }
    }
}