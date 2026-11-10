// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SitoCash.sol";

contract SitoCashTest is Test {
    SitoCash token;
    address owner = address(0x1);
    address userExcluded = address(0x2);
    address userStandard = address(0x3);
    uint256 constant INITIAL_BALANCE = 1000 ether;
    address constant UNISWAP_ROUTER = 0x509c97d4A7b98C91f1264304f228e3639416F118;

    function setUp() public {
        // Create mock addresses for Uniswap components
        address mockFactory = address(0x1234);
        address mockWETH = address(0x5678);
        address mockPair = address(0x90ABC);
        
        // Mock Uniswap router and factory calls
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        vm.startPrank(owner);
        token = new SitoCash(owner);
        
        // Set initial 0% fees for setup transfers
        token.setTaxFeePercent(0);
        token.setLiquidityFeePercent(0);
        
        // Fund test account
        token.transfer(userStandard, INITIAL_BALANCE);
        
        // Configure for test case (within 4% limit)
        token.setTaxFeePercent(4);
        token.setLiquidityFeePercent(0);
        
        // Prepare excluded account
        token.excludeFromReward(userExcluded);
        vm.stopPrank();
    }

    // Struct to bundle token state variables
    struct TokenState {
        uint256 senderBalance;
        uint256 recipientBalance;
        uint256 totalFees;
        uint256 contractBalance;
    }

    function testTransferToExcludedUpdatesBalancesCorrectly() public {
        uint256 transferAmount = 100 ether;
        // Expected amounts calculated directly
        uint256 expectedFee = 100 ether * 4 / 100; // 4% fee
        uint256 expectedReceived = 100 ether - expectedFee;

        // Pre-transfer states grouped in struct
        TokenState memory before = TokenState({
            senderBalance: token.balanceOf(userStandard),
            recipientBalance: token.balanceOf(userExcluded),
            totalFees: token.totalFees(),
            contractBalance: token.balanceOf(address(token))
        });

        console2.log("--- BEFORE-Trigger Transfer ---");
        console2.log("Sender Balance (Before):    %s", before.senderBalance);
        console2.log("Recipient Balance (Before): %s", before.recipientBalance);
        console2.log("Total Fees (Before):        %s", before.totalFees);
        console2.log("Contract Balance (Before):  %s", before.contractBalance);

        console2.log("--- Trigger Transfer ---");
        vm.prank(userStandard);
        token.transfer(userExcluded, transferAmount);

        // Post-transfer states in struct
        TokenState memory afterState = TokenState({
            senderBalance: token.balanceOf(userStandard),
            recipientBalance: token.balanceOf(userExcluded),
            totalFees: token.totalFees(),
            contractBalance: token.balanceOf(address(token))
        });

        console2.log("--- AFTER-Trigger Transfer ---");
        console2.log("Sender Balance (After):     %s", afterState.senderBalance);
        console2.log("Recipient Balance (After):  %s", afterState.recipientBalance);
        console2.log("Total Fees (After):         %s", afterState.totalFees);
        console2.log("Contract Balance (After):   %s", afterState.contractBalance);

        // Differential calculations
        uint256 senderChange = before.senderBalance - afterState.senderBalance;
        uint256 recipientChange = afterState.recipientBalance - before.recipientBalance;
        uint256 feeChange = afterState.totalFees - before.totalFees;
        uint256 contractChange = afterState.contractBalance - before.contractBalance;

        console2.log("--------- Differential Results --------");
        console2.log("Expected Sender Change:    -%s", transferAmount);
        console2.log("Actual Sender Change:      -%s", senderChange);
        console2.log("");
        console2.log("Expected Recipient Change:  %s", expectedReceived);
        console2.log("Actual Recipient Change:    %s", recipientChange);
        console2.log("");
        console2.log("Expected Fee Change:        %s", expectedFee);
        console2.log("Actual Fee Change:          %s", feeChange);
        console2.log("");
        console2.log("Expected Contract Change:   0");
        console2.log("Actual Contract Change:     %s", contractChange);
        console2.log("---------------------------------------");

        // Vulnerability detection by direct comparison
        bool vulExists = false;
        if (senderChange != transferAmount) {
            console2.log("Invalid sender balance change");
            vulExists = true;
        }
        if (recipientChange != expectedReceived) {
            console2.log("Invalid recipient balance change");
            vulExists = true;
        }
        if (feeChange != expectedFee) {
            console2.log("Invalid fee amount");
            vulExists = true;
        }
        if (contractChange != 0) {
            console2.log("Unexpected contract balance change");
            vulExists = true;
        }

        // Final verdict
        if (vulExists) {
            console2.log("Vulnerability Exists: Invalid state transitions detected");
        } else {
            console2.log("Vulnerability not Exist: All state changes match expectations");
        }
    }
}