// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ElonsPets.sol";

contract MockRouter {
    function factory() public pure returns (address) {
        return address(0xfAc7);
    }

    function WETH() public pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract MockFactory {
    function createPair(address, address) public pure returns (address) {
        return address(0x123456);
    }
}

contract ElonsPetsTest is Test {
    ElonsPets token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;

    function setUp() public {
        // Deploy and configure mock Uniswap contracts
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();

        // Place mock bytecode at required addresses
        vm.etch(address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D), address(mockRouter).code);
        vm.etch(address(0xfAc7), address(mockFactory).code);

        // Deploy token contract with mock environment
        vm.startPrank(owner);
        token = new ElonsPets();
        
        // Configure token fees (1% burn fee only)
        token.setBurnFee(100); // 100 basis points = 1%
        token.setTaxFee(0);
        token.setLiquidityFee(0);
        token.setFeeActive(true);
        
        // Prepare test accounts
        token.setExcludedFromMaxWallet(bob, true);
        token.setMaxWalletAmount(type(uint256).max);
        
        // Send initial tokens to Alice (1/4 of total supply)
        uint256 decimals = token.decimals();
        uint256 initialAmount = token.totalSupply() / 4;
        token.transfer(alice, initialAmount);
        vm.stopPrank();
    }

    function testBurnVulnerability() public {
        uint256 decimals = token.decimals();
        uint256 initialSupply = token.totalSupply();
        
        // Transfer amount and expected values
        uint256 transferAmount = 1000 * 10 ** decimals;
        uint256 expectedBurn = transferAmount; // Entire amount burned due to vulnerability
        uint256 expectedTransfer = 0; // Recipient receives nothing

        // Get initial balances
        uint256 aliceBefore = token.balanceOf(alice);
        uint256 bobBefore = token.balanceOf(bob);
        uint256 deadBefore = token.balanceOf(DEAD);
        uint256 supplyBefore = token.totalSupply();

        // Log pre-trigger state
        console.log("--- BEFORE-Trigger State ---");
        console.log("Alice balance:", aliceBefore);
        console.log("Bob balance:", bobBefore);
        console.log("DEAD balance:", deadBefore);
        console.log("Total Supply:", supplyBefore);

        console.log("--- Trigger Transfer ---");
        console.log("Performing transfer: Alice -> Bob", transferAmount);
        console.log("Expected behavior: 100% burn - Bob should receive nothing");

        // Perform transfer (triggers vulnerability)
        vm.prank(alice);
        token.transfer(bob, transferAmount);

        // Get balances after transfer
        uint256 aliceAfter = token.balanceOf(alice);
        uint256 bobAfter = token.balanceOf(bob);
        uint256 deadAfter = token.balanceOf(DEAD);
        uint256 supplyAfter = token.totalSupply();

        console.log("--- AFTER-Trigger State ---");
        console.log("Alice balance:", aliceAfter);
        console.log("Bob balance:", bobAfter);
        console.log("DEAD balance:", deadAfter);
        console.log("Total Supply:", supplyAfter);

        // Calculate state changes
        uint256 aliceLoss = aliceBefore - aliceAfter;
        uint256 bobGain = bobAfter - bobBefore;
        uint256 deadGain = deadAfter - deadBefore;
        uint256 supplyLoss = supplyBefore - supplyAfter;

        console.log("--- State Changes ---");
        console.log("Alice loss:", aliceLoss);
        console.log("Bob gain:", bobGain);
        console.log("DEAD gain:", deadGain);
        console.log("Supply reduction:", supplyLoss);

        // Verify vulnerability exploitation
        bool isVulnerable = (aliceLoss == transferAmount) && 
                           (bobGain == expectedTransfer) && 
                           (deadGain == expectedBurn) && 
                           (supplyLoss == expectedBurn);

        // Final verdict
        if (isVulnerable) {
            console.log("VULNERABILITY EXISTS: Entire transfer amount burned due to fee miscalculation");
        } else {
            console.log("VULNERABILITY NOT EXIST: Transfer behavior does not match 100% burn pattern");
        }
    }
}