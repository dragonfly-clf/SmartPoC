// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCCS.sol";

contract SCCSTest is Test {
    SCCS token;
    address owner;
    address user = address(0x1);
    address mockPair = address(0x2);
    uint256 constant INITIAL_SUPPLY = 100_000_000_000 * 1e18;
    uint256 constant TEST_AMOUNT = 1000 * 1e18;

    function setUp() public {
        owner = address(this);
        token = new SCCS();
        
        // Initialize token with mock pair address
        token.setPairAddress(mockPair);
        token.transfer(user, TEST_AMOUNT * 100);
    }

    function testBurnInconsistency() public {
        // Validate initial token state
        console.log("--- Initial State Snapshot ---");
        console.log("User Balance:", token.balanceOf(user));
        console.log("Total Supply:", token.totalSupply());
        console.log("Pair Balance:", token.balanceOf(mockPair));
        console.log("");

        // ========== First Burn Method: Transfer to Pair ==========
        console.log("--- PRE: Transfer to Pair Burn ---");
        uint256 preTransferUserBalance = token.balanceOf(user);
        uint256 preTransferTotalSupply = token.totalSupply();
        uint256 preTransferPairBalance = token.balanceOf(mockPair);
        console.log("User Balance (Before):", preTransferUserBalance);
        console.log("Total Supply (Before):", preTransferTotalSupply);
        console.log("Pair Balance (Before):", preTransferPairBalance);
        console.log("");
        
        // Execute transfer burn
        console.log("--- Trigger Operation: Transfer to Pair ---");
        vm.prank(user);
        token.transfer(mockPair, TEST_AMOUNT);
        console.log("Executed transfer: ", TEST_AMOUNT, " tokens to pair");
        console.log("");
        
        console.log("--- POST: Transfer to Pair Burn ---");
        uint256 postTransferUserBalance = token.balanceOf(user);
        uint256 postTransferTotalSupply = token.totalSupply();
        uint256 postTransferPairBalance = token.balanceOf(mockPair);
        console.log("User Balance (After):", postTransferUserBalance);
        console.log("Total Supply (After):", postTransferTotalSupply);
        console.log("Pair Balance (After):", postTransferPairBalance);
        
        // Calculate changes from first burn
        uint256 transferBurnUserLoss = preTransferUserBalance - postTransferUserBalance;
        uint256 transferBurnSupplyReduction = preTransferTotalSupply - postTransferTotalSupply;
        uint256 transferBurnPairGain = postTransferPairBalance - preTransferPairBalance;
        console.log("");
        console.log("[DIFF] Transfer-to-Pair Burn effect");
        console.log("  User Balance Change: -", transferBurnUserLoss);
        console.log("  Total Supply Change: -", transferBurnSupplyReduction);
        console.log("  Pair Balance Change: +", transferBurnPairGain);
        console.log("");
        
        // ========== Second Burn Method: Public Burn ==========
        console.log("--- PRE: Public Burn Method ---");
        uint256 prePublicBurnUserBalance = token.balanceOf(user);
        uint256 prePublicBurnTotalSupply = token.totalSupply();
        uint256 prePublicBurnPairBalance = token.balanceOf(mockPair);
        console.log("User Balance (Before):", prePublicBurnUserBalance);
        console.log("Total Supply (Before):", prePublicBurnTotalSupply);
        console.log("Pair Balance (Before):", prePublicBurnPairBalance);
        console.log("");
        
        // Execute public burn
        console.log("--- Trigger Operation: Public Burn ---");
        vm.prank(user);
        token.publicBurn(TEST_AMOUNT);
        console.log("Executed publicBurn: ", TEST_AMOUNT, " tokens");
        console.log("");
        
        console.log("--- POST: Public Burn Method ---");
        uint256 postPublicBurnUserBalance = token.balanceOf(user);
        uint256 postPublicBurnTotalSupply = token.totalSupply();
        uint256 postPublicBurnPairBalance = token.balanceOf(mockPair);
        console.log("User Balance (After):", postPublicBurnUserBalance);
        console.log("Total Supply (After):", postPublicBurnTotalSupply);
        console.log("Pair Balance (After):", postPublicBurnPairBalance);
        
        // Calculate changes from second burn
        uint256 publicBurnUserLoss = prePublicBurnUserBalance - postPublicBurnUserBalance;
        uint256 publicBurnSupplyReduction = prePublicBurnTotalSupply - postPublicBurnTotalSupply;
        uint256 publicBurnPairGain = postPublicBurnPairBalance - prePublicBurnPairBalance;
        console.log("");
        console.log("[DIFF] Public Burn effect");
        console.log("  User Balance Change: -", publicBurnUserLoss);
        console.log("  Total Supply Change: -", publicBurnSupplyReduction);
        console.log("  Pair Balance Change: +", publicBurnPairGain);
        console.log("");
        
        // ========== Differential Verification ==========
        console.log("--- Vulnerability Check ---");
        console.log("Comparing burn method effects (transfer vs publicBurn):");
        console.log("User Balance Consistency? ", transferBurnUserLoss == publicBurnUserLoss ? "SAME" : "DIFFERENT");
        console.log("Total Supply Consistency? ", transferBurnSupplyReduction == publicBurnSupplyReduction ? "SAME" : "DIFFERENT");
        console.log("Pair Balance Consistency? ", transferBurnPairGain == publicBurnPairGain ? "SAME" : "DIFFERENT");
        
        // Final verdict
        if (transferBurnUserLoss != publicBurnUserLoss || 
            transferBurnSupplyReduction != publicBurnSupplyReduction || 
            transferBurnPairGain != publicBurnPairGain) {
            console.log("Vulnerability exists: Inconsistent burn behavior detected");
        } else {
            console.log("Vulnerability not exist: Consistent burn behavior");
        }
    }
}