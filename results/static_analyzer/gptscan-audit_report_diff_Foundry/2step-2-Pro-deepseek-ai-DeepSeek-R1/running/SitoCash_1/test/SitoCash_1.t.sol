// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SitoCash.sol";

contract MWE209Test is Test {
    SitoCash token;
    address owner = address(this);
    address excludedAccount = address(0xB);
    address regularAccount = address(0xC);
    address constant ROUTER_ADDRESS = address(0x509c97d4A7b98C91f1264304f228e3639416F118);
    address constant MOCK_FACTORY = address(0x1234567890123456789012345678901234567890);
    address constant MOCK_WETH = address(0x4567890123456789012345678901234567890123);
    address constant MOCK_PAIR = address(0x7890123456789012345678901234567890123456);

    function setUp() public {
        vm.startPrank(owner);
        // Mock Uniswap router and factory responses
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        token = new SitoCash(owner);
        
        // Set appropriate fees to avoid revert
        token.setTaxFeePercent(4);
        token.setLiquidityFeePercent(1);
        
        // Set high token balance threshold to prevent swap during test
        token.setMinimumTokenBalance(10**30);
        
        // Exclude account and fund it
        token.excludeFromReward(excludedAccount);
        uint256 ownerBalance = token.balanceOf(owner);
        token.transfer(excludedAccount, ownerBalance / 2);
        
        vm.stopPrank();
    }

    function test_feeProcessingOrderVulnerability() public {
        assertTrue(token.isExcludedFromReward(excludedAccount), "Sender not excluded");
        assertTrue(!token.isExcludedFromReward(regularAccount), "Recipient not included");

        uint256 amount = 1e6;
        
        console2.log("--- BEFORE-Trigger Transfer ---");
        // Get prestine reflection rate
        uint256 initialRate = token.reflectionFromToken(1 ether, true);
        console2.log("Initial reflection rate:", initialRate);
        
        console2.log("--- Trigger Transfer ---");
        /** Test triggers _transferFromExcluded flow:
         * 1. Sender is excluded from rewards
         * 2. Recipient is included in rewards
         */
        vm.prank(excludedAccount);
        token.transfer(regularAccount, amount);

        console2.log("--- AFTER-Trigger Transfer ---");
        uint256 finalRate = token.reflectionFromToken(1 ether, true);
        console2.log("Final reflection rate:", finalRate);
        
        // Compare rates to detect vulnerability
        bool vulnerabilityExists = finalRate < initialRate;
        console2.log("Reflection rate decreased:", vulnerabilityExists);
        
        // Final verdict based on reflection rate comparison
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Reflection rate decreased abnormally after transfer, indicating fee processing vulnerability");
        } else {
            console2.log("Vulnerability not Exist: No abnormal reflection rate change detected");
        }

        // Original assertion preserved
        assertLt(finalRate, initialRate, "Reflection rate should differ");
    }
}