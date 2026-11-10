// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/StdStorage.sol";
import "../src/0x7a8721a9d64c74da899424c1b52acbf58ddc9782.sol";

contract PrivateDepositTest is Test {
    using stdStorage for StdStorage;
    
    PrivateDeposit privateDeposit;
    address depositor = address(0xCAFE);

    function setUp() public {
        privateDeposit = new PrivateDeposit();
    }

    function testOverflowInDepositFunction() public {
        // 1. Get minimum deposit amount from contract
        uint256 minDeposit = privateDeposit.MinDeposit();
        
        // 2. Set initial balance to max - minDeposit + 1 (vulnerable threshold)
        uint256 initialBalance = type(uint256).max - minDeposit + 1;
        stdstore.target(address(privateDeposit))
            .sig("balances(address)")
            .with_key(depositor)
            .checked_write(initialBalance);

        // 3. Verify initial balance is correctly set
        assertEq(privateDeposit.balances(depositor), initialBalance);
        
        // Differential verification start
        console.log("--- BEFORE-Trigger Deposit ---");
        uint256 balanceBefore = privateDeposit.balances(depositor);
        console.log("Depositor balance (before): %s", balanceBefore);

        console.log("--- Trigger Deposit ---");
        // 4. Fund depositor and perform deposit
        vm.deal(depositor, minDeposit);
        vm.prank(depositor);
        privateDeposit.Deposit{value: minDeposit}();
        
        console.log("--- AFTER-Trigger Deposit ---");
        uint256 balanceAfter = privateDeposit.balances(depositor);
        console.log("Depositor balance (after): %s", balanceAfter);
        
        // 5. Verify overflow ocurred (balance wrapped around to 0) and determine vulnerability
        if (balanceAfter == 0) {
            console.log("Vulnerability verified: Balance overflowed to 0");
            console.log("Vulnerability Exists: Arithmetic overflow not prevented");
        } else {
            console.log("Vulnerability not verified: Expected 0 after overflow, got %s", balanceAfter);
            console.log("Vulnerability not Exist: Overflow prevented or did not occur");
        }
    }
}