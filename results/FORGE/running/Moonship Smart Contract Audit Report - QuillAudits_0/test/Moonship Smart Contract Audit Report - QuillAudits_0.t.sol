// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/moonship.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    address public constant WETH = address(0x456);
    
    constructor() public {
        factory = address(new MockFactory());
    }
}

contract MoonShipAuditTest is Test {
    MoonShip token;
    address owner = address(0x1);
    address whale = address(0x2);
    address recipient = address(0x3);
    MockRouter mockRouter;

    function setUp() public {
        mockRouter = new MockRouter();
        vm.startPrank(owner);
        token = new MoonShip(payable(address(mockRouter)));
        
        // Disable liquidity features to isolate tax calculation
        token.setSwapAndLiquifyEnabled(false);
        token.setTaxFeePercent(10);  // Set 10% tax
        token.setLiquidityFeePercent(0);
        token.excludeFromFee(owner); // Exclude owner from fees
        vm.stopPrank();
    }

    function test_DisruptiveTransferAppliesTax() public {
        // Get initial total supply
        uint256 totalSupply = token.totalSupply();
        
        // Calculate whale amount (0.1% of supply, above 0.01% threshold)
        uint256 whaleAmount = totalSupply / 1000;

        // Transfer tokens to whale from owner
        vm.prank(owner);
        token.transfer(whale, whaleAmount);
        
        // Get whale's initial balance in tokens (not reflections)
        uint256 initialWhaleTokenBalance = token.balanceOf(whale);
        require(initialWhaleTokenBalance == whaleAmount, "Incorrect whale balance");

        // Fund whale with BNB for disruptive fee
        vm.deal(whale, 2 ether);
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialRecipientBalance = token.balanceOf(recipient);
        console.log("Recipient Initial Balance: ", initialRecipientBalance);
        console.log("Whale Initial Balance: ", initialWhaleTokenBalance);
        
        console.log("--- Trigger DisruptiveTransfer ---");
        // Execute disruptive transfer with 2 ETH payment
        vm.prank(whale);
        token.disruptiveTransfer{value: 2 ether}(recipient, initialWhaleTokenBalance);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalRecipientBalance = token.balanceOf(recipient);
        uint256 finalWhaleBalance = token.balanceOf(whale);
        console.log("Recipient Final Balance: ", finalRecipientBalance);
        console.log("Whale Final Balance: ", finalWhaleBalance);
        
        uint256 receivedAmount = finalRecipientBalance - initialRecipientBalance;
        
        // Calculate expected amount after 10% tax
        uint256 expectedAmount = (initialWhaleTokenBalance * 90) / 100;
        
        // Calculate 1% tolerance for reflection mechanics
        uint256 tolerance = initialWhaleTokenBalance / 100;
        
        // Check conditions for vulnerability existence
        bool taxAppliedCorrectly = receivedAmount >= expectedAmount - tolerance && 
                                  receivedAmount <= expectedAmount + tolerance;
        bool whaleBalanceZeroed = finalWhaleBalance == 0;
        bool vulnerabilityExists = taxAppliedCorrectly && whaleBalanceZeroed;
        
        console.log("--- Verdict ---");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Disruptive transfer applied tax and correctly modified balances");
        } else {
            console.log("Vulnerability not Exist: Balance changes not consistent with tax exploitation");
        }

        // Original validation logic (unchanged)
        // Verify recipient received approximately 90% of tokens
        assertApproxEqAbs(
            receivedAmount,
            expectedAmount,
            tolerance,
            "Recipient did not receive approximately 90% after tax"
        );
        
        // Verify whale lost all sent tokens
        assertEq(token.balanceOf(whale), 0, "Whale balance not zeroed");
    }
}