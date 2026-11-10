// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Equality.sol";

contract EqualityStopTransactionsTest is Test {
    Equality public token;
    address public constant MOCK_ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public owner = address(this);
    address public alice = address(0x1);
    address public bob = address(0x2);
    address public dummyPair = address(0x3);
    
    function setUp() public {
        // Mock Uniswap components
        vm.mockCall(
            MOCK_ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(address(0x5))
        );
        vm.mockCall(
            MOCK_ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(address(0x6))
        );
        vm.mockCall(
            address(0x5),
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(dummyPair)
        );

        // Deploy token with mock environment
        token = new Equality();
        
        // Setup test conditions
        uint256 totalSupply = token.totalSupply();
        token.transfer(alice, totalSupply / 2);
        token.enableDisableWalletLimit(false);
        token.setBuyTaxes(0, 0, 0);
        token.setSelTaxes(0, 0, 0);
        token.setMaxTxAmount(type(uint256).max);
        token.setMarketPairStatus(dummyPair, true);
    }

    function test_MaxTxAmountZeroBlocksTransfer() public {
        uint256 amount = 10 * 10 ** token.decimals();
        
        console.log("\n--- BEFORE-Trigger (Normal Transfer) ---");
        console.log("Initial maxTxAmount:", token._maxTxAmount());
        console.log("Alice balance:", token.balanceOf(alice));
        console.log("Bob balance:", token.balanceOf(bob));
        
        // Successful transfer before setting maxTxAmount = 0
        uint256 bobBefore = token.balanceOf(bob);
        vm.prank(alice);
        token.transfer(bob, amount);
        uint256 bobAfter = token.balanceOf(bob);
        
        console.log("Transfer succeeded with balance change:", bobAfter - bobBefore);
        console.log("Initial tx limit works correctly");
        
        console.log("\n--- Trigger: Change maxTxAmount to 0 ---");
        token.setMaxTxAmount(0);
        console.log("New maxTxAmount:", token._maxTxAmount());
        
        console.log("\n--- AFTER-Trigger (Transfer Attempt) ---");
        uint256 aliceBefore = token.balanceOf(alice);
        bobBefore = token.balanceOf(bob);
        console.log("Alice balance:", aliceBefore);
        console.log("Bob balance:", bobBefore);
        
        // Attempt transfer after zero limit setting
        vm.startPrank(alice);
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        token.transfer(bob, amount);
        vm.stopPrank();
        
        uint256 aliceAfter = token.balanceOf(alice);
        bobAfter = token.balanceOf(bob);
        console.log("Transfer reverted - Alice balance unchanged:", aliceAfter - aliceBefore);
        console.log("Bob balance unchanged:", bobAfter - bobBefore);
        
        bool vulnerable = aliceAfter == aliceBefore && bobAfter == bobBefore;
        console.log("\nVulnerability: Owner can block transfers by setting maxTxAmount=0");
        assertTrue(vulnerable, "Vulnerability verified: Transfers blocked");
    }

    function test_HighSellTaxPreventsSelling() public {
        uint256 amount = 10 * 10 ** token.decimals();
        
        console.log("\n--- BEFORE-Trigger (Sell with 0% Tax) ---");
        console.log("Initial sell tax rate:", token._totalTaxIfSelling());
        uint256 aliceBefore = token.balanceOf(alice);
        uint256 treasuryBefore = token.balanceOf(address(token));
        uint256 pairBefore = token.balanceOf(dummyPair);
        console.log("Alice balance:", aliceBefore);
        console.log("Treasury balance:", treasuryBefore);
        console.log("Market pair balance:", pairBefore);
        
        // Sell with no taxes
        vm.prank(alice);
        token.transfer(dummyPair, amount);
        
        uint256 aliceAfter = token.balanceOf(alice);
        uint256 treasuryAfter = token.balanceOf(address(token));
        uint256 pairAfter = token.balanceOf(dummyPair);
        console.log("\nSell succeeded with 0%% tax:");
        console.log("Alice balance change:", aliceBefore - aliceAfter);
        console.log("Treasury balance change:", treasuryAfter - treasuryBefore);
        console.log("Pair balance change:", pairAfter - pairBefore);
        
        // Set high sell tax (using 99% to avoid integer division issues)
        console.log("\n--- Trigger: Set Sell Tax to 99% ---");
        token.setSelTaxes(0, 0, 99);
        console.log("New sell tax rate:", token._totalTaxIfSelling());
        
        console.log("\n--- AFTER-Trigger (Sell with 99% Tax) ---");
        aliceBefore = token.balanceOf(alice);
        treasuryBefore = token.balanceOf(address(token));
        pairBefore = token.balanceOf(dummyPair);
        console.log("Alice balance:", aliceBefore);
        console.log("Treasury balance:", treasuryBefore);
        console.log("Market pair balance:", pairBefore);
        
        vm.prank(alice);
        token.transfer(dummyPair, amount);
        
        aliceAfter = token.balanceOf(alice);
        treasuryAfter = token.balanceOf(address(token));
        pairAfter = token.balanceOf(dummyPair);
        console.log("\nSell results with 99%% tax:");
        console.log("Alice balance change:", aliceBefore - aliceAfter);
        console.log("Treasury balance change:", treasuryAfter - treasuryBefore);
        console.log("Pair balance change:", pairAfter - pairBefore);
        
        // Verify tax distribution
        uint256 aliceDelta = aliceBefore - aliceAfter;
        uint256 treasuryDelta = treasuryAfter - treasuryBefore;
        uint256 pairDelta = pairAfter - pairBefore;
        bool vulnerable = (aliceDelta == amount) && 
                          (treasuryDelta + pairDelta == amount) &&
                          (treasuryDelta > amount * 98 / 100);
        
        if (vulnerable) {
            console.log("\nVulnerability Exists: Owner can set nearly 100% sell tax");
        } else {
            console.log("\nVulnerability not Exist: Sell taxes within expected range");
        }
    }
}