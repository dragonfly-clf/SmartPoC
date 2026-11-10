// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol"; // Added for differential logs
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract TokenBank_UnderflowTest is Test {
    TokenBank tokenBank;
    VulnerableToken token;
    address owner = address(1);
    address to = address(2);

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        token = new VulnerableToken();
        vm.stopPrank();
    }

    function test_withdrawnTokenUnderflow() public {
        uint256 initialBalance = 100 ether;
        uint256 withdrawalAmount = 101 ether; // Attempt to withdraw more than balance

        // Setup token balances
        token.mint(address(tokenBank), initialBalance);
        assertEq(token.balanceOf(address(tokenBank)), initialBalance);

        console2.log("--- BEFORE-Trigger WithdrawnToken ---");
        uint256 bankBefore = token.balanceOf(address(tokenBank));
        uint256 recipientBefore = token.balanceOf(to);
        console2.log("Bank Balance Before:", bankBefore);
        console2.log("Recipient Balance Before:", recipientBefore);

        // Owner attempts to withdraw more tokens than the bank holds
        console2.log("--- Trigger WithdrawnToken ---");
        vm.prank(owner);
        tokenBank.WithdrawToken(address(token), withdrawalAmount, to);

        console2.log("--- AFTER-Trigger WithdrawnToken ---");
        uint256 bankAfter = token.balanceOf(address(tokenBank));
        uint256 recipientAfter = token.balanceOf(to);
        console2.log("Bank Balance After:", bankAfter);
        console2.log("Recipient Balance After:", recipientAfter);

        // Compute expected underflow results
        uint256 expectedBankBalance;
        unchecked {
            expectedBankBalance = initialBalance - withdrawalAmount;
        }
        
        // Vulnerability verification
        bool balancesChanged = (bankAfter != bankBefore) && (recipientAfter != recipientBefore);
        bool underflowOccurred = bankAfter == expectedBankBalance;
        bool receivedTokens = recipientAfter == withdrawalAmount;
        
        // Final vulnerability verdict
        if (underflowOccurred && receivedTokens && balancesChanged) {
            console2.log("Vulnerability Exists: Bank balance underflow occurred and recipient received tokens beyond bank balance");
        } else {
            console2.log("Vulnerability not Exist: No underflow occurred or recipient did not receive expected tokens");
        }
        
        // Original validations remain
        assertEq(token.balanceOf(address(tokenBank)), expectedBankBalance, "Token bank balance should underflow");
        assertEq(token.balanceOf(to), withdrawalAmount, "Recipient should receive withdrawn tokens");
    }
}

contract VulnerableToken {
    mapping(address => uint256) public balances;

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    function mint(address to, uint256 amount) public {
        balances[to] += amount;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        // Vulnerable implementation - allows underflow in unchecked
        unchecked {
            balances[msg.sender] -= amount;
        }
        balances[to] += amount;
        return true;
    }
}