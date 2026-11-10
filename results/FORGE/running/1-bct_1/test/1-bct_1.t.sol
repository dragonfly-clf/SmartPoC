// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CHITAVERSE.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    }

    function WETH() external pure returns (address) {
        return 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x456);
    }
}

contract CHITAVERSEFeeTest is Test {
    CHITAVERSE public token;
    address public owner = makeAddr("owner");
    address public constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant FACTORY_ADDRESS = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;

    function setUp() public {
        // Deploy mocks to required addresses
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();

        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.etch(FACTORY_ADDRESS, address(mockFactory).code);

        // Deploy main contract
        vm.startPrank(owner);
        token = new CHITAVERSE();
        vm.stopPrank();
    }

    function test_SetFeesAbove25Percent() public {
        console.log("=========== test: setFees above 25% ===========");
        
        console.log("--- BEFORE setting fees ---");
        uint256 totalBuyFeeBefore = token.getTotalFee(false);
        uint256 totalSellFeeBefore = token.getTotalFee(true);
        uint256 sellMultiplierBefore = token._sellMultiplier();
        console.log("Initial buy fee (bps):   %s", totalBuyFeeBefore);
        console.log("Initial sell fee (bps):  %s", totalSellFeeBefore);
        console.log("Initial sell multiplier: %s", sellMultiplierBefore);
        
        console.log("--- Trigger setFees(10,10,10,100) ---");
        vm.startPrank(owner);
        token.setFees(10, 10, 10, 100); // Total fees = 30% (above 25%)
        vm.stopPrank();
        
        console.log("--- AFTER setting fees ---");
        uint256 totalBuyFeeAfter = token.getTotalFee(false);
        uint256 totalSellFeeAfter = token.getTotalFee(true);
        uint256 sellMultiplierAfter = token._sellMultiplier();
        console.log("Updated buy fee (bps):   %s", totalBuyFeeAfter);
        console.log("Updated sell fee (bps):  %s", totalSellFeeAfter);
        console.log("Updated sell multiplier: %s", sellMultiplierAfter);
        
        // Vulnerability check (25% = 2500 basis points)
        if(totalBuyFeeAfter > 2500 || totalSellFeeAfter > 2500) {
            console.log("VULNERABILITY VERIFIED: Fees exceed 25% limit");
            console.log("Vulnerability Exists: Owner can set fees above 25% threshold");
        } else {
            console.log("ACCEPTABLE: Fees remain under 25% limit");
            console.log("Vulnerability not Exist: Fees within acceptable range");
        }
    }

    function test_SetHighSellMultiplier() public {
        console.log("\n=========== test: set high sell multiplier ===========");
        
        console.log("--- BEFORE setting multiplier ---");
        uint256 sellMultiplierBefore = token._sellMultiplier();
        uint256 totalSellFeeBefore = token.getTotalFee(true);
        console.log("Initial sell multiplier: %s", sellMultiplierBefore);
        console.log("Initial total sell fee (bps): %s", totalSellFeeBefore);
        
        console.log("--- Trigger setSellMultiplier(1000) ---");
        vm.startPrank(owner);
        token.setSellMultiplier(1000); // Unreasonably high multiplier
        vm.stopPrank();
        
        console.log("--- AFTER setting multiplier ---");
        uint256 sellMultiplierAfter = token._sellMultiplier();
        uint256 totalSellFeeAfter = token.getTotalFee(true);
        console.log("Updated sell multiplier: %s", sellMultiplierAfter);
        console.log("Updated total sell fee (bps): %s", totalSellFeeAfter);
        
        if(sellMultiplierAfter == 1000) {
            console.log("VULNERABILITY VERIFIED: Sell multiplier set to dangerous value (1000)");
            console.log("Vulnerability Exists: Owner can set extreme sell multiplier");
        } else {
            console.log("ACCEPTABLE: Sell multiplier within safe range");
            console.log("Vulnerability not Exist: Sell multiplier change unsuccessful");
        }
    }
}