// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    address owner = makeAddr("owner");
    address holder = makeAddr("holder");
    
    // Mock ERC20 token for safe transfer testing
    ERC20Mock token;

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        token = new ERC20Mock();
        vm.stopPrank();
        
        // Initialize holder with tokens exceeding MinDeposit
        vm.deal(holder, 2 ether);
        vm.prank(holder);
        tokenBank.Deposit{value: 2 ether}();
        
        // Verify holder deposit was successful
        assertEq(tokenBank.Holders(holder), 2 ether);
    }

    function test_ArithmeticOperationSafety() public {
        console2.log("--- BEFORE-Trigger Holder Balance ---");
        uint256 holderBalanceBefore = tokenBank.Holders(holder);
        console2.log("Holder balance before withdraw:", holderBalanceBefore);
        // Ensure initial state is correct
        assert(holderBalanceBefore > 0);
        
        console2.log("--- Trigger WitdrawTokenToHolder ---");
        vm.prank(owner);
        tokenBank.WitdrawTokenToHolder(holder, address(token), 1e18);
        
        console2.log("--- AFTER-Trigger Holder Balance ---");
        uint256 holderBalanceAfter = tokenBank.Holders(holder);
        console2.log("Holder balance after withdraw:", holderBalanceAfter);
        
        // Vulnerability Verification with final log
        if (holderBalanceAfter == 0) {
            console2.log("Vulnerability Exists: The holder's entire deposit was cleared unexpectedly");
        } else {
            console2.log("Vulnerability not Exist: Holder balance updated normally");
        }
    }
}

contract ERC20Mock {
    mapping(address => uint256) public balanceOf;

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[to] += amount;
        return true;
    }
}