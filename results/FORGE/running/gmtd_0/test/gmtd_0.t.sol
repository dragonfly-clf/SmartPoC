// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GMTdoge.sol";

contract MockFactory {
    address immutable pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address immutable _factory;
    address immutable _weth;
    
    constructor(address factoryAddr, address wethAddr) {
        _factory = factoryAddr;
        _weth = wethAddr;
    }
    
    function factory() external view returns (address) {
        return _factory;
    }
    
    function WETH() external view returns (address) {
        return _weth;
    }
}

contract GMTdogeTest is Test {
    GMTdoge token;
    address owner = address(0x1);
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant PAIR_ADDRESS = address(0x1234);
    address constant WETH_ADDRESS = address(0xc0fFee);

    function setUp() public {
        // Deploy mock factory pointing to our mock pair
        MockFactory mockFactory = new MockFactory(PAIR_ADDRESS);
        
        // Deploy mock router using mock factory and mock WETH
        MockRouter mockRouter = new MockRouter(address(mockFactory), WETH_ADDRESS);
        
        // Implant mock router code at real PancakeSwap router address
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        
        // Create minimal contract at pair address
        vm.etch(PAIR_ADDRESS, hex"01");
        
        // Create token as owner
        vm.prank(owner);
        token = new GMTdoge();
    }

    function testFeeExceeds25Percent() public {
        console.log("--- BEFORE setFees ---");
        // Query initial total fee
        uint256 totalFeeBefore = token.getTotalFee(false);
        console.log("Initial total fee:", totalFeeBefore);

        console.log("--- Trigger setFees (30% total) ---");
        // Construct dangerous fee structure
        uint256 liquidityFee = 10;
        uint256 buybackFee = 10;
        uint256 reflectionFee = 5;
        uint256 marketingFee = 5;
        uint256 feeDenominator = 100;

        // Set fees as owner
        vm.startPrank(owner);
        token.setFees(
            liquidityFee,
            buybackFee,
            reflectionFee,
            marketingFee,
            feeDenominator
        );
        vm.stopPrank();

        console.log("--- AFTER setFees ---");
        // Query total fee after manipulation
        uint256 totalFeeAfter = token.getTotalFee(false);
        console.log("New total fee:", totalFeeAfter);
        
        // Vulnerability verification
        if (totalFeeAfter > 25) {
            console.log("Vulnerability Exists: Total fee %s%% exceeds 25%% limit", totalFeeAfter);
        } else {
            console.log("Vulnerability not Exist: Total fee %s%% within limits", totalFeeAfter);
        }
    }
}