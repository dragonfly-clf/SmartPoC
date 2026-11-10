// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Munkai.sol";

contract MockRouter {
    address public factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xC0FFEE);
    }
}

contract FeeManipulationTest is Test {
    Munkai token;
    MockFactory mockFactory;
    MockRouter mockRouter;
    address owner = address(0xABCD);
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory), WETH_ADDRESS);
        
        vm.prank(owner);
        token = new Munkai(address(mockRouter));
    }

    // Valid fee setting below 25% (at 24%)
    function testValidFee() public {
        uint256 successDenominator = 10000;
        vm.prank(owner);
        // 24% total fees (600+600+600+600 = 2400)
        token.setFees(600, 600, 600, 600, successDenominator);
    }

    // Exactly 25% should revert
    function testExactly25PercentReverts() public {
        uint256 denominator = 10000;
        vm.prank(owner);
        vm.expectRevert();
        // 2500 = 25% of 10000
        token.setFees(625, 625, 625, 625, denominator);
    }

    // Above 25% should revert
    function testAbove25PercentReverts() public {
        uint256 denominator = 10000;
        vm.prank(owner);
        vm.expectRevert();
        // 2501 = 25.01% of 10000
        token.setFees(625, 625, 625, 626, denominator);
    }
}