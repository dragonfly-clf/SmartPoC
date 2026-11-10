// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KARMA.sol";

contract KARMASupplyTest is Test {
    KARMA token;
    address owner = makeAddr("owner");
    
    // Mock addresses for Uniswap
    address constant ROUTER = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address mockFactory = address(0x1234);
    address mockWETH = address(0x5678);
    address mockPair = address(0xabcd);

    function setUp() public {
        // Set chain ID for router selection
        vm.chainId(1);

        // Precompute token address
        uint256 nonce = vm.getNonce(owner);
        address tokenAddress = vm.computeCreateAddress(owner, nonce);

        // Mock router calls
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature(
                "createPair(address,address)", 
                tokenAddress, 
                mockWETH
            ),
            abi.encode(mockPair)
        );

        // Deploy token
        vm.startPrank(owner);
        token = new KARMA();
        token.enableTrading();
        vm.stopPrank();
    }

    function test_TotalSupplyDivergenceAfterBurn() public {
        // Configure fees to include burn fee
        vm.startPrank(owner);
        token.excludeFromFees(owner, false);
        token.setBuyFeePercentages(0, 0, 0, 100); // Burn fee = 100/1000 = 10%
        token.setSellFeePercentages(0, 0, 0, 100);
        vm.stopPrank();

        // Pre-transfer state
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 transferAmount = ownerBalanceBefore / 2;

        console.log("Total Supply Before:     ", totalSupplyBefore);
        console.log("Owner Balance Before:    ", ownerBalanceBefore);
        console.log("Dead Address Before:     ", token.balanceOf(address(0xdead)));
        console.log("Token Contract Before:   ", token.balanceOf(address(token)));
        console.log("Pair Before:             ", token.balanceOf(mockPair));

        uint256 balanceSumBefore = ownerBalanceBefore 
            + token.balanceOf(address(0xdead))
            + token.balanceOf(address(token))
            + token.balanceOf(mockPair);
        console.log("Balance Sum Before:      ", balanceSumBefore);

        console.log("--- TRIGGER: Transfer (with 10% burn fee) ---");
        vm.prank(owner);
        token.transfer(mockPair, transferAmount);

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 ownerBalanceAfter = token.balanceOf(owner);

        console.log("Total Supply After:      ", totalSupplyAfter);
        console.log("Owner Balance After:     ", ownerBalanceAfter);
        console.log("Dead Address After:      ", token.balanceOf(address(0xdead)));
        console.log("Token Contract After:    ", token.balanceOf(address(token)));
        console.log("Pair After:              ", token.balanceOf(mockPair));

        uint256 balanceSumAfter = ownerBalanceAfter 
            + token.balanceOf(address(0xdead))
            + token.balanceOf(address(token))
            + token.balanceOf(mockPair);
        console.log("Balance Sum After:       ", balanceSumAfter);

        // Correctly calculate expected burn amount with 1000 divisor
        uint256 feePercentage = 100; 
        uint256 expectedBurnAmount = transferAmount * feePercentage / 1000;
        uint256 actualSupplyGap = balanceSumAfter - totalSupplyAfter;

        // Determine vulnerability status
        string memory verdict;
        if (totalSupplyBefore == balanceSumBefore && totalSupplyAfter < balanceSumAfter) {
            verdict = "Vulnerability Exists: Total supply diverges from balance sum after burn fee";
        } else {
            verdict = "Vulnerability not Exist: Pre-condition or burn effect did not trigger";
        }

        console.log("Supply Discrepancy:      %d total vs %d sum", totalSupplyAfter, balanceSumAfter);
        console.log("Expected Burn Amount:    %d", expectedBurnAmount);
        console.log("Actual Supply Gap:       %d", actualSupplyGap);
        console.log(verdict);

        // Final vulnerability validation
        if (totalSupplyBefore == balanceSumBefore && totalSupplyAfter < balanceSumAfter) {
            console.log("Vulnerability confirmed: Total supply diverges after burn");
        } else {
            console.log("No vulnerability confirmed: Supply consistency maintained");
        }

        // Existing assertions for completeness
        assertLt(
            totalSupplyAfter,
            balanceSumAfter,
            "Total supply is less than sum of balances"
        );
        
        assertApproxEqAbs(
            actualSupplyGap,
            expectedBurnAmount,
            1e16,  // Allow small rounding difference
            "Supply discrepancy matches expected burn amount"
        );
    }
}