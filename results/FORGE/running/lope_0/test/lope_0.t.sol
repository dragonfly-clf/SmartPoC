// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LOPE.sol";
import "forge-std/console.sol";

contract LOPE_Honeypot_Test is Test {
    LOPE public token;
    address public owner = address(0x1);
    address public user = address(0x2);
    address public pair;
    uint256 constant transferAmount = 100 ether;
    
    function setUp() public {
        // Use default public RPC URL if environment variable isn't set
        string memory rpcUrl = "https://bsc-dataseed.binance.org/";
        try vm.envString("BSC_RPC_URL") returns (string memory envUrl) {
            rpcUrl = envUrl;
        } catch {}
        
        // Create fork using either environment URL or default
        vm.createSelectFork(rpcUrl);

        // Deploy token contract
        vm.startPrank(owner);
        token = new LOPE();
        pair = token.uniswapV2Pair();
        token.transfer(user, 1000 ether);
        vm.stopPrank();
    }

    function test_StopTransactions() public {
        // Disable swapping to avoid interference
        vm.prank(owner);
        token.setSwapEnabled(false);

        console.log("\n--- Baseline Transfer: BEFORE ---");
        uint256 baselineUserBefore = token.balanceOf(user);
        uint256 baselinePairBefore = token.balanceOf(pair);
        uint256 baselineTokenBefore = token.balanceOf(address(token));
        console.log("User Balance    :", baselineUserBefore);
        console.log("Pair Balance    :", baselinePairBefore);
        console.log("Contract Balance:", baselineTokenBefore);

        // Perform baseline transfer with normal fees
        vm.prank(user);
        token.transfer(pair, transferAmount);

        console.log("\n--- Baseline Transfer: AFTER ---");
        uint256 baselineUserAfter = token.balanceOf(user);
        uint256 baselinePairAfter = token.balanceOf(pair);
        uint256 baselineTokenAfter = token.balanceOf(address(token));
        uint256 baselineUserLoss = baselineUserBefore - baselineUserAfter;
        uint256 baselinePairGain = baselinePairAfter - baselinePairBefore;
        uint256 baselineTokenGain = baselineTokenAfter - baselineTokenBefore;
        console.log("User Loss    :", baselineUserLoss);
        console.log("Pair Gain    :", baselinePairGain);
        console.log("Contract Gain:", baselineTokenGain);

        // Validate baseline behavior (normal fees)
        assertEq(
            baselineUserLoss,
            transferAmount,
            "User should lose full transfer amount normally"
        );
        assertGt(
            baselinePairGain,
            0,
            "Pair should receive tokens under normal fees"
        );
        assertEq(
            baselineTokenGain,
            transferAmount - baselinePairGain,
            "Contract should get difference as fee"
        );

        // Set sell fee to 100% to create honeypot
        console.log("\n--- TRIGGER: Applying 100% Fee ---");
        vm.prank(owner);
        token.setSellFee(100, 0);

        console.log("\n--- Honeypot Transfer: BEFORE ---");
        uint256 honeyUserBefore = token.balanceOf(user);
        uint256 honeyPairBefore = token.balanceOf(pair);
        uint256 honeyTokenBefore = token.balanceOf(address(token));
        console.log("User Balance    :", honeyUserBefore);
        console.log("Pair Balance    :", honeyPairBefore);
        console.log("Contract Balance:", honeyTokenBefore);

        // Simulate sell transaction
        vm.prank(user);
        token.transfer(pair, transferAmount);

        console.log("\n--- Honeypot Transfer: AFTER ---");
        uint256 honeyUserAfter = token.balanceOf(user);
        uint256 honeyPairAfter = token.balanceOf(pair);
        uint256 honeyTokenAfter = token.balanceOf(address(token));
        uint256 honeyUserLoss = honeyUserBefore - honeyUserAfter;
        uint256 honeyPairGain = honeyPairAfter - honeyPairBefore;
        uint256 honeyTokenGain = honeyTokenAfter - honeyTokenBefore;
        console.log("User Loss    :", honeyUserLoss);
        console.log("Pair Gain    :", honeyPairGain);
        console.log("Contract Gain:", honeyTokenGain);

        // Differential comparison
        console.log("\n=== DIFFERENTIAL VERDICT ===");
        bool feeCaptureValid = honeyTokenGain == transferAmount;
        bool noPairReceipt = honeyPairGain == 0;
        
        console.log("Contract captured 100% fee:", feeCaptureValid ? "SUCCESS" : "FAILURE");
        console.log("Pair received zero tokens:", noPairReceipt ? "SUCCESS" : "FAILURE");
        
        if (feeCaptureValid && noPairReceipt && honeyUserLoss == transferAmount) {
            console.log("Vulnerability Exists: Honeypot effect confirmed: Contract captured 100% of transfer value");
        } else {
            console.log("Vulnerability not Exist: Failed to demonstrate honeypot effect");
        }

        // Final validations
        assertEq(
            honeyUserAfter,
            honeyUserBefore - transferAmount,
            "User balance should decrease by full transfer amount"
        );
        assertEq(
            honeyPairAfter,
            honeyPairBefore,
            "Pair balance should remain unchanged due to 100% fee"
        );
        assertEq(
            honeyTokenAfter,
            honeyTokenBefore + transferAmount,
            "Contract should capture the entire transfer as fee"
        );
    }
}