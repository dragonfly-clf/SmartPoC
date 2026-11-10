// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ELONTICKER.sol";

contract MockWETH {
    function deposit() public payable {}
    function transfer(address to, uint value) public returns (bool) {}
    function withdraw(uint) public {}
}

contract FeeTest is Test {
    ELONTICKER public token;
    address owner = address(0x1);
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock WETH
        MockWETH mockWeth = new MockWETH();
        address mockFactory = makeAddr("factory");
        address mockPair = makeAddr("pair");

        // Mock router's factory() call to return mockFactory
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router's WETH() call to return mockWeth address
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(mockWeth))
        );
        
        // Mock factory's createPair() to return mockPair address
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token
        vm.startPrank(owner);
        token = new ELONTICKER();
        vm.stopPrank();
    }

    function testExtraSellFeeExceedsLimit() public {
        uint256 rewardFee = 8;
        uint256 liquidityFee = 8;
        uint256 marketingFee = 8;

        vm.startPrank(owner);
        token.setrewardFees(rewardFee);
        token.setLiquidityFee(liquidityFee);
        token.setmarketingFee(marketingFee);
        
        console.log("--- BEFORE-Trigger ExtraSellFee ---");
        uint256 preExtraSellFee = token.extraSellFee();
        console.log("Initial extraSellFee value:", preExtraSellFee);

        console.log("--- Trigger: Setting extraSellFee(5) ---");
        // Set extra sell fee that pushes total above 25% (24% base + 5% extra)
        token.setExtraSellFee(5);

        console.log("--- AFTER-Trigger ExtraSellFee ---");
        uint256 postExtraSellFee = token.extraSellFee();
        console.log("Updated extraSellFee value:", postExtraSellFee);

        // Final vulnerability assessment
        if (postExtraSellFee == 5) {
            console.log("Vulnerability Exists: extraSellFee was modified to exceed maximum allowed fee cap");
        } else {
            console.log("Vulnerability not Exist: extraSellFee modification failed or did not persist");
        }
        vm.stopPrank();
    }
}