// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SpriteCore.sol";

contract SpriteCoreTest is Test {
    SpriteCore token;
    address owner = makeAddr("owner");
    address admin = makeAddr("admin");
    address user = makeAddr("user");
    address attackContract = address(new DummyContract());
    
    // EIP-712 compliant CONTROL_ROLE hash
    bytes32 constant CONTROL_ROLE = keccak256("CONTROL_ROLE");

    function setUp() public {
        // Deploy token with initial supply
        vm.prank(owner);
        token = new SpriteCore(1000 ether, admin);
        
        // Setup admin roles
        vm.startPrank(owner);
        token.grantRole(token.DEFAULT_ADMIN_ROLE(), admin);
        token.grantRole(CONTROL_ROLE, admin);
        vm.stopPrank();
        
        // Fund accounts - manual setup instead of getAccount()
        deal(address(token), admin, 500 ether);
        deal(address(token), user, 500 ether);
    }

    function test_ZeroAddressWithdraw() public {
        uint256 initialAdminBalance = token.balanceOf(admin);
        
        vm.prank(admin);
        vm.expectRevert("ERC20: transfer to the zero address");
        token.withDraw(address(0), 100 ether);
        
        // Verify no balance changes
        assertEq(token.balanceOf(admin), initialAdminBalance, "Admin balance changed");
    }

    function test_WithdrawToContract() public {
        uint256 amount = 100 ether;
        
        console.log("--- BEFORE-Trigger Withdraw ---");
        uint256 adminBalanceBefore = token.balanceOf(admin);
        uint256 contractBalanceBefore = token.balanceOf(attackContract);
        console.log("Admin balance (before): ", adminBalanceBefore);
        console.log("Attack contract balance (before):", contractBalanceBefore);
        console.log("Withdraw amount:", amount);

        console.log("--- Trigger Withdraw ---");
        vm.prank(admin);
        token.withDraw(attackContract, amount);
        console.log("Executed: token.withDraw(attackContract, amount)");

        console.log("--- AFTER-Trigger Withdraw ---");
        uint256 adminBalanceAfter = token.balanceOf(admin);
        uint256 contractBalanceAfter = token.balanceOf(attackContract);
        console.log("Admin balance (after): ", adminBalanceAfter);
        console.log("Attack contract balance (after): ", contractBalanceAfter);

        uint256 adminDecrease = adminBalanceBefore - adminBalanceAfter;
        uint256 contractIncrease = contractBalanceAfter - contractBalanceBefore;
        console.log("Admin decrease:", adminDecrease);
        console.log("Contract increase:", contractIncrease);

        // Vulnerability verification with single verdict output
        if (adminDecrease == amount && contractIncrease == amount) {
            console.log("Vulnerability Exists: Admin can arbitrarily drain funds to any address via withDraw()");
        } else {
            console.log("Vulnerability not Exist: Balance changes do not match withdraw amount");
        }

        // Original assertions
        assertEq(contractBalanceAfter, contractBalanceBefore + amount, "Contract didn't receive tokens");
        assertEq(adminBalanceAfter, adminBalanceBefore - amount, "Admin balance not deducted");
    }
}

contract DummyContract {}