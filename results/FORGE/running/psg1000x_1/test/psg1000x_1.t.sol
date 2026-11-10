// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PresidentsSquidGame.sol";

contract FeeLimitTest is Test {
    PresidentsSquidGame token;
    address owner = makeAddr("owner");
    
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0x1111);
    address mockWETH = address(0x2222);
    address mockPair = address(0x3333);

    function setUp() public {
        // Start as owner to deploy the token
        vm.startPrank(owner);
        
        // Compute future token address
        uint256 nonce = vm.getNonce(owner);
        address computedToken = computeCreateAddress(owner, nonce);

        // Mock router and factory calls without redeclaring interfaces
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(0xc45a0155), // factory() function selector
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(0xad5c4648), // WETH() function selector
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(0xc9c65396, computedToken, mockWETH), // createPair(address,address)
            abi.encode(mockPair)
        );

        // Deploy token
        token = new PresidentsSquidGame();
        vm.stopPrank();
    }

    function test_buy_fee_exceeds_limit() public {
        uint256 exceededFee = 26;
        
        console.log("--- BEFORE-Trigger ---");
        uint256 initialBuyFee = token.BuyFee();
        console.log("Initial Buy Fee: %s%%", initialBuyFee);
        
        console.log("--- Trigger: setBuyFee(%s) ---", exceededFee);
        vm.prank(owner);
        token.setBuyFee(exceededFee);
        
        console.log("--- AFTER-Trigger ---");
        uint256 newBuyFee = token.BuyFee();
        console.log("New Buy Fee: %s%%", newBuyFee);
        
        assertEq(newBuyFee, exceededFee, "Buy fee was not set correctly");
        
        // Differential validation
        if (newBuyFee > 25) {
            console.log(">>> Vulnerability Confirmed: Buy fee exceeds 25%% limit");
            console.log("Vulnerability Exists: Buy fee can exceed 25%% limit");
        } else {
            console.log(">>> Validation Passed: Buy fee within limits");
            console.log("Vulnerability not Exist: Buy fee enforcement works");
        }
    }

    function test_sell_fee_exceeds_limit() public {
        uint256 exceededFee = 26;
        
        console.log("--- BEFORE-Trigger ---");
        uint256 initialSellFee = token.SellFee();
        console.log("Initial Sell Fee: %s%%", initialSellFee);
        
        console.log("--- Trigger: setSellFee(%s) ---", exceededFee);
        vm.prank(owner);
        token.setSellFee(exceededFee);
        
        console.log("--- AFTER-Trigger ---");
        uint256 newSellFee = token.SellFee();
        console.log("New Sell Fee: %s%%", newSellFee);
        
        assertEq(newSellFee, exceededFee, "Sell fee was not set correctly");
        
        // Differential validation
        if (newSellFee > 25) {
            console.log(">>> Vulnerability Confirmed: Sell fee exceeds 25%% limit");
            console.log("Vulnerability Exists: Sell fee can exceed 25%% limit");
        } else {
            console.log(">>> Validation Passed: Sell fee within limits");
            console.log("Vulnerability not Exist: Sell fee enforcement works");
        }
    }
}