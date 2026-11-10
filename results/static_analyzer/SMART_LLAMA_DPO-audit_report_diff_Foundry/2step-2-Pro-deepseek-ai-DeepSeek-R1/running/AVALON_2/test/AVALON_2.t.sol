// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AVALON.sol";

contract AvalonAuditTest is Test {
    AVALON token;
    address constant server = address(0x3427d4b12875D5f459b25B993FfbaE2243571ca8);
    address user = address(0x123);
    address constant HARDCODED_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address mockFactory = address(0xFAC70);
    address mockPair = address(0xABCD);
    uint32 constant withdrawCount = 0;
    uint256 INITIAL_TOTAL_SUPPLY = 1000000000 * 1e9;
    uint256 amountToSend = 100 ether;

    function setUp() public {
        // Mock router factory and WETH
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH)
        );
        
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Deploy token
        token = new AVALON(address(0));
        
        // Transfer initial tokens to server through taxable system
        token.transfer(server, amountToSend);
        
        // Verify server received tokens without fee deduction
        assertTrue(
            token.balanceOf(server) == amountToSend, 
            "Server balance incorrectly funded"
        );
    }

    function testReplayVulnerability() public {
        int256 withdrawalAmount = 1 ether;
        uint256 initialUserBalance = token.balanceOf(user);
        console.log("--- BEFORE-Trigger Withdrawal (First) ---");
        console.log("User Balance Before: %e", initialUserBalance);

        // First withdrawal - should work
        vm.prank(server);
        token.Withdraw(user, withdrawalAmount, withdrawCount);
        uint256 balanceAfterFirst = token.balanceOf(user);
        console.log("First withdrawal successful");
        console.log("--- AFTER-Trigger Withdrawal (First) ---");
        console.log("User Balance After: %e", balanceAfterFirst);
        console.log("Actual Withdrawn: %e", balanceAfterFirst - initialUserBalance);

        // Verify first withdrawal occurred correctly
        uint256 expectedAfterFirst = initialUserBalance + uint256(withdrawalAmount);
        assertEq(balanceAfterFirst, expectedAfterFirst, "Balance after first withdrawal incorrect");

        console.log("--- BEFORE-Trigger Withdrawal (Second) ---");
        uint256 beforeSecondBalance = token.balanceOf(user);
        console.log("User Balance Before Second: %e", beforeSecondBalance);

        // Attempt second withdrawal using same nonce - should ALWAYS revert
        vm.prank(server);
        vm.expectRevert("Cannot complete transaction because transactioncount doesn't equal server's signed value signature");
        token.Withdraw(user, withdrawalAmount, withdrawCount);
        console.log("Second withdrawal correctly reverted");

        console.log("--- AFTER-Trigger Withdrawal (Second) ---");
        uint256 afterSecondBalance = token.balanceOf(user);
        console.log("User Balance After: %e", afterSecondBalance);
        console.log("Balance Change: %e", afterSecondBalance - beforeSecondBalance);

        // Determine vulnerability existence
        string memory verdict;
        if (afterSecondBalance != beforeSecondBalance) {
            verdict = "Vulnerability Exists: Repeated withdrawal with same nonce succeeded";
        } else {
            verdict = "Vulnerability not Exist: Balance unchanged after second withdrawal";
        }
        console.log(verdict);
    }
}