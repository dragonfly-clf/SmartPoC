// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

contract MockLog {
    function AddMessage(address, uint, string memory) public {}
}

contract PRIVATE_ETH_CELL_Test is Test {
    PRIVATE_ETH_CELL private vault;
    MockLog private mockLog;
    address private constant user = address(0x123);
    uint256 private constant WEAK_EDGE = type(uint256).max - 100 ether + 1;
    uint256 private constant SAFE_EDGE = type(uint256).max - 200 ether;

    function setUp() public {
        vault = new PRIVATE_ETH_CELL();
        mockLog = new MockLog();
        vault.SetLogFile(address(mockLog));
        // Base slot determined to be 0 after testing
    }

    function test_UncheckedDeposit_Overflow() public {
        // Correct storage slot calculation for mapping base slot 0
        bytes32 userSlot = keccak256(abi.encodePacked(uint256(uint160(user)), uint256(0)));
        vm.store(address(vault), userSlot, bytes32(WEAK_EDGE));

        // Verify storage setup
        assertEq(vault.balances(user), WEAK_EDGE, "Initial balance set failure");
        vm.deal(user, 100 ether);
        
        console2.log("--- BEFORE-Trigger Deposit ---");
        uint256 vaultBalanceBefore = vault.balances(user);
        uint256 ethBalanceBefore = user.balance;
        console2.log("Vault balance: %s wei", vaultBalanceBefore);
        console2.log("User ETH balance: %s wei", ethBalanceBefore);

        console2.log("--- Trigger Deposit ---");
        vm.prank(user);
        vault.Deposit{value: 100 ether}();

        console2.log("--- AFTER-Trigger Deposit ---");
        uint256 vaultBalanceAfter = vault.balances(user);
        uint256 ethBalanceAfter = user.balance;
        console2.log("Vault balance: %s wei", vaultBalanceAfter);
        console2.log("User ETH balance: %s wei", ethBalanceAfter);

        // Validate overflow occurred
        assertEq(vaultBalanceAfter, 0, "Overflow should reset to 0");

        // Final vulnerability verdict based on state comparison
        if (vaultBalanceAfter < vaultBalanceBefore) {
            console2.log("Vulnerability Exists: Deposit caused overflow reducing balance");
        } else {
            console2.log("Vulnerability not Exist: Deposit completed without overflow");
        }
    }

    function test_UncheckedDeposit_Safe() public {
        // Correct storage slot calculation with base slot 0
        bytes32 userSlot = keccak256(abi.encodePacked(uint256(uint160(user)), uint256(0)));
        vm.store(address(vault), userSlot, bytes32(SAFE_EDGE));

        // Perform safe deposit
        uint256 depositAmount = 100 ether;
        vm.deal(user, depositAmount);
        vm.prank(user);
        vault.Deposit{value: depositAmount}();

        // Validate balance updated safely
        assertEq(
            vault.balances(user),
            SAFE_EDGE + depositAmount,
            "Balance should update without overflow"
        );
    }
}