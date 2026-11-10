// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Fame.sol";

contract FameTransactionStoppageTest is Test {
    Fame token;
    address owner = address(this);
    address user = address(0xA);
    
    // Mock addresses
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address MOCK_WETH = address(0xDEAD);
    address MOCK_FACTORY = address(0xBEEF);
    address MOCK_PAIR = address(0xCAFE);

    function setUp() public {
        // Setup mock responses for router
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory createPair response
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(MOCK_PAIR)
        );
        
        // Deploy token
        token = new Fame();
        
        // Set initial state
        token.transfer(user, 100 ether);
        
        // CRITICAL: Disable swap and liquify to prevent interference
        token.setSwapAndLiquifyEnabled(false);
    }

    function testMaxTxAmountZeroBlocksTransactions() public {
        // Set max transaction amount to zero
        token.setMaxTxAmount(0);

        // Attempt to transfer tokens from user
        vm.prank(user);
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        token.transfer(address(0xB), 1 wei);
    }

    function testHighSellTaxHoneypot() public {
        // Set sell tax to 100% (0 liquidity, 100 marketing, 0 team)
        token.setSelTaxes(0, 100, 0);
        
        uint256 transferAmount = 10 ether;

        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 contractBalanceBefore = token.balanceOf(address(token));
        uint256 pairBalanceBefore = token.balanceOf(MOCK_PAIR);
        
        console.log("User Balance Before: ", userBalanceBefore);
        console.log("Contract Balance Before: ", contractBalanceBefore);
        console.log("Pair Balance Before: ", pairBalanceBefore);

        console.log("--- Trigger Transfer ---");
        // User transfers to pair (simulated sell transaction)
        vm.prank(user);
        token.transfer(MOCK_PAIR, transferAmount);

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 contractBalanceAfter = token.balanceOf(address(token));
        uint256 pairBalanceAfter = token.balanceOf(MOCK_PAIR);
        
        console.log("User Balance After: ", userBalanceAfter);
        console.log("Contract Balance After: ", contractBalanceAfter);
        console.log("Pair Balance After: ", pairBalanceAfter);
        
        // Compute balance changes
        uint256 userBalanceChange = userBalanceBefore - userBalanceAfter;
        uint256 contractBalanceChange = contractBalanceAfter - contractBalanceBefore;
        uint256 pairBalanceChange = pairBalanceAfter - pairBalanceBefore;
        
        console.log("User Balance Change: ", userBalanceChange);
        console.log("Contract Balance Change: ", contractBalanceChange);
        console.log("Pair Balance Change: ", pairBalanceChange);
        
        // Validate honeypot scenario through differential comparison
        bool pairReceivesNothing = (pairBalanceChange == 0);
        bool contractCapturesAll = (contractBalanceChange == transferAmount);
        bool userLosesAll = (userBalanceChange == transferAmount);
        bool exploitSuccessful = pairReceivesNothing && contractCapturesAll && userLosesAll;
        
        // Final vulnerability verification
        if (exploitSuccessful) {
            console.log("Vulnerability Exists: High sell tax (100%) allows honeypot scenario ");
        } else {
            console.log("Vulnerability not Exist: Transfer behavior does not match honeypot pattern");
        }
        
        // Assert results (retained original verification logic)
        assertEq(pairBalanceAfter, 0, "Pair received tokens despite 100% tax");
        assertEq(
            contractBalanceAfter, 
            contractBalanceBefore + transferAmount,
            "Contract didn't capture full fee amount"
        );
        assertEq(
            userBalanceAfter,
            userBalanceBefore - transferAmount,
            "User balance not reduced by transfer amount"
        );
    }
}