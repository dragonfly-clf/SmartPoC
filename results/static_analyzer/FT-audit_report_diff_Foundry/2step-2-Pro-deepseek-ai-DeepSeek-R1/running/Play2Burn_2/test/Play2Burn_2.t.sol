// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Play2Burn.sol";

contract Play2BurnFeeTest is Test {
    // Define local FeeStructure to match Play2Burn
    struct FeeStructure {
        uint16 liquidityFee;
        uint16 marketingFee;
        uint16 rewardFee;
        uint16 taxFee;
    }

    Play2Burn token;
    address owner = address(0x1);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant MOCK_FACTORY = 0x1230000000000000000000000000000000000000;
    address constant MOCK_PAIR = 0x4560000000000000000000000000000000000000;

    // Helper to get buyFee via low-level call
    function getBuyFee() internal view returns (FeeStructure memory) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSignature("buyFee()")
        );
        require(success, "buyFee call failed");
        return abi.decode(data, (FeeStructure));
    }

    // Helper to get sellFee via low-level call
    function getSellFee() internal view returns (FeeStructure memory) {
        (bool success, bytes memory data) = address(token).staticcall(
            abi.encodeWithSignature("sellFee()")
        );
        require(success, "sellFee call failed");
        return abi.decode(data, (FeeStructure));
    }

    function setUp() public {
        // Mock router factory function using signature
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock router WETH function using signature
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH_ADDRESS)
        );
        
        // Mock factory createPair function using signature
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        // Label accounts for better traces
        vm.label(owner, "Owner");
        vm.label(ROUTER_ADDRESS, "UniswapRouter");
        vm.label(MOCK_FACTORY, "MockFactory");
        vm.label(MOCK_PAIR, "MockPair");

        // Deploy token as owner
        vm.startPrank(owner);
        token = new Play2Burn();
        vm.stopPrank();
    }

    function testSetBuyFeeAboveLimit() public {
        // Get initial fee state
        FeeStructure memory initialBuyFee = getBuyFee();
        uint256 initialTotalBuyFee = initialBuyFee.liquidityFee + initialBuyFee.marketingFee + initialBuyFee.rewardFee + initialBuyFee.taxFee;
        
        console2.log("--- BEFORE-Trigger SetBuyFee ---");
        console2.log("Initial Buy Fee Structure:");
        console2.log("Liquidity Fee:", initialBuyFee.liquidityFee);
        console2.log("Marketing Fee:", initialBuyFee.marketingFee);
        console2.log("Reward Fee:", initialBuyFee.rewardFee);
        console2.log("Tax Fee:", initialBuyFee.taxFee);
        console2.log("Total Buy Fee:", initialTotalBuyFee);
        
        // Trigger vulnerability - set fee above safe threshold
        console2.log("--- Trigger SetBuyFee (40%) ---");
        vm.prank(owner);
        token.setBuyFee(10, 10, 10, 10); // 40%
        
        // Get fee state after manipulation
        FeeStructure memory manipulatedBuyFee = getBuyFee();
        uint256 manipulatedTotalBuyFee = manipulatedBuyFee.liquidityFee + manipulatedBuyFee.marketingFee + manipulatedBuyFee.rewardFee + manipulatedBuyFee.taxFee;
        
        console2.log("--- AFTER-Trigger SetBuyFee ---");
        console2.log("Manipulated Buy Fee Structure:");
        console2.log("Liquidity Fee:", manipulatedBuyFee.liquidityFee);
        console2.log("Marketing Fee:", manipulatedBuyFee.marketingFee);
        console2.log("Reward Fee:", manipulatedBuyFee.rewardFee);
        console2.log("Tax Fee:", manipulatedBuyFee.taxFee);
        console2.log("Total Buy Fee:", manipulatedTotalBuyFee);
        
        // Validate test results
        bool exceedsLimit = manipulatedTotalBuyFee > 25; // Safe threshold is 25%
        bool setToTarget = manipulatedTotalBuyFee == 40; // Verify no revert occurred
        
        console2.log("Total fee exceeds 25% limit:", exceedsLimit ? "YES" : "NO");
        console2.log("Fees set to 40% as requested:", setToTarget ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (exceedsLimit && setToTarget) {
            console2.log("Vulnerability Exists: Owner can set buy fees beyond 25% threshold");
        } else {
            console2.log("Vulnerability not Exist: Buy fee changes reverted or within safe limit");
        }
    }

    function testSetSellFeeAboveLimit() public {
        // Get initial fee state
        FeeStructure memory initialSellFee = getSellFee();
        uint256 initialTotalSellFee = initialSellFee.liquidityFee + initialSellFee.marketingFee + initialSellFee.rewardFee + initialSellFee.taxFee;
        
        console2.log("--- BEFORE-Trigger SetSellFee ---");
        console2.log("Initial Sell Fee Structure:");
        console2.log("Liquidity Fee:", initialSellFee.liquidityFee);
        console2.log("Marketing Fee:", initialSellFee.marketingFee);
        console2.log("Reward Fee:", initialSellFee.rewardFee);
        console2.log("Tax Fee:", initialSellFee.taxFee);
        console2.log("Total Sell Fee:", initialTotalSellFee);
        
        // Trigger vulnerability - set fee above safe threshold
        console2.log("--- Trigger SetSellFee (40%) ---");
        vm.prank(owner);
        token.setSellFee(10, 10, 10, 10); // 40%
        
        // Get fee state after manipulation
        FeeStructure memory manipulatedSellFee = getSellFee();
        uint256 manipulatedTotalSellFee = manipulatedSellFee.liquidityFee + manipulatedSellFee.marketingFee + manipulatedSellFee.rewardFee + manipulatedSellFee.taxFee;
        
        console2.log("--- AFTER-Trigger SetSellFee ---");
        console2.log("Manipulated Sell Fee Structure:");
        console2.log("Liquidity Fee:", manipulatedSellFee.liquidityFee);
        console2.log("Marketing Fee:", manipulatedSellFee.marketingFee);
        console2.log("Reward Fee:", manipulatedSellFee.rewardFee);
        console2.log("Tax Fee:", manipulatedSellFee.taxFee);
        console2.log("Total Sell Fee:", manipulatedTotalSellFee);
        
        // Validate test results
        bool exceedsLimit = manipulatedTotalSellFee > 25; // Safe threshold is 25%
        bool setToTarget = manipulatedTotalSellFee == 40; // Verify no revert occurred
        
        console2.log("Total fee exceeds 25% limit:", exceedsLimit ? "YES" : "NO");
        console2.log("Fees set to 40% as requested:", setToTarget ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (exceedsLimit && setToTarget) {
            console2.log("Vulnerability Exists: Owner can set sell fees beyond 25% threshold");
        } else {
            console2.log("Vulnerability not Exist: Sell fee changes reverted or within safe limit");
        }
    }
}