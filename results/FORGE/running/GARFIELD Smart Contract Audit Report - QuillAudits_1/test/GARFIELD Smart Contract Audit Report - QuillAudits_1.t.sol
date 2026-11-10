// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GARFIELD.sol";

contract GARFIELDTest is Test {
    GARFIELD token;
    MockPancakeRouter router;
    address owner = address(0x1);
    address whale = address(0x2);
    address receiver = address(0x3);
    
    function setUp() public {
        // Deploy with owner
        vm.startPrank(owner);
        router = new MockPancakeRouter();
        token = new GARFIELD(payable(address(router)));
        
        // Configure token settings
        token.setSwapAndLiquifyEnabled(false);  // Disable swapAndLiquify
        token.setTaxFeePercent(5);
        token.setLiquidityFeePercent(5);
        
        // Prepare whale with tokens (0.02% of total supply)
        uint256 totalSupply = token.totalSupply();
        uint256 whaleAmount = totalSupply * 20 / 100000;  // 0.02%
        token.transfer(whale, whaleAmount);
        
        // Exclude whale from maxTx limits
        token.setExcludeFromMaxTx(whale, true);
        vm.stopPrank();
        
        // Fund whale with 10 ETH for disruptive fee
        vm.deal(whale, 10 ether);
    }

    function test_DisruptiveTransferAppliesTax() public {
        // Pre-attack state snapshot
        console.log("--- BEFORE-Trigger Statistics ---");
        uint256 whaleInitialBalance = token.balanceOf(whale);
        console.log("Whale initial balance: %s tokens", whaleInitialBalance);
        uint256 receiverInitialBalance = token.balanceOf(receiver);
        console.log("Receiver initial balance: %s tokens", receiverInitialBalance);
        uint256 taxFeeBefore = token._taxFee();
        console.log("Current tax fee: %s basis points", taxFeeBefore);

        // Check transfer amount threshold
        uint256 maxTxPercent = (token.totalSupply()) / 10000;  // 0.01%
        assertGt(
            whaleInitialBalance, 
            maxTxPercent, 
            "Transfer amount too small to trigger disruptive tax"
        );

        // Attack trigger - disruptive transfer
        console.log("--- TRIGGER: Disruptive Transfer ---");
        console.log("Whale pays 2 ETH fee for disruptive transfer");
        vm.prank(whale);
        token.disruptiveTransfer{value: 2 ether}(receiver, whaleInitialBalance);

        // Post-attack state snapshot
        console.log("--- AFTER-Trigger Statistics ---");
        uint256 whaleBalanceAfter = token.balanceOf(whale);
        console.log("Whale final balance: %s tokens", whaleBalanceAfter);
        uint256 receiverBalanceAfter = token.balanceOf(receiver);
        console.log("Receiver final balance: %s tokens", receiverBalanceAfter);
        uint256 taxFeeAfter = token._taxFee();
        console.log("Current tax fee: %s basis points", taxFeeAfter);
        
        // Differential validation
        uint256 receivedAmount = receiverBalanceAfter - receiverInitialBalance;
        uint256 expectedWithoutTax = whaleInitialBalance;
        uint256 expectedWithTax = whaleInitialBalance * 9 / 10; // 90% of amount
        
        console.log("--- Tax Application Analysis ---");
        console.log("Actual amount received: %s tokens", receivedAmount);
        console.log("Expected amount without tax: %s tokens", expectedWithoutTax);
        console.log("Expected amount with 10%% tax: %s tokens", expectedWithTax);
        
        // Calculate deviation from expected tax application
        uint256 deviationFromNoTax = absDiff(receivedAmount, expectedWithoutTax);
        uint256 deviationFromWithTax = absDiff(receivedAmount, expectedWithTax);
        
        bool taxCorrectlyApplied = deviationFromWithTax < whaleInitialBalance * 1 / 100; // 1% tolerance
        bool taxNotApplied = deviationFromNoTax < whaleInitialBalance * 1 / 100;
        
        console.log("Deviation from expected tax: %s tokens", deviationFromWithTax);
        console.log("Deviation from no-tax: %s tokens", deviationFromNoTax);
        
        // Final vulnerability verdict
        if (taxCorrectlyApplied) {
            console.log("Vulnerability confirmed: Disruptive transfer applied 10%% tax");
        } else if (taxNotApplied) {
            console.log("Security feature: No tax applied during disruptive transfer");
        } else {
            console.log("Anomaly: Unexpected tax rate applied");
        }
        
        // Formal vulnerability verdict as required
        if (taxCorrectlyApplied) {
            emit log_string("Vulnerability Exists: Disruptive transfer incorrectly applied 10% tax");
        } else {
            emit log_string("Vulnerability not Exist: Tax application behaves as expected");
        }
    }

    // Helper for absolute difference
    function absDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : b - a;
    }

    // Fallback to receive ETH
    receive() external payable {}
}

// Mock PancakeSwap contracts
contract MockPancakeFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdead);
    }
}

contract MockPancakeRouter {
    address public pancakeFactory;
    address public constant WETH = address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    
    constructor() public {
        pancakeFactory = address(new MockPancakeFactory());
    }
    
    function factory() external view returns (address) {
        return pancakeFactory;
    }
}