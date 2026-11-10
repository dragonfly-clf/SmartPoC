// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Mobsterblox.sol";

contract MockWETH {
    function deposit() external payable {}
    fallback() external payable {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xdead);
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH;

    constructor(address _weth) {
        factory = address(new MockFactory());
        WETH = _weth;
    }
}

contract MobsterbloxTest is Test {
    Mobsterblox public token;
    address constant owner = address(0x123);
    address constant serviceAddress = address(0x456);
    MockRouter public initialRouter;
    address public mockWeth;
    uint256 public constant MAX_UINT = type(uint256).max;
    
    function setUp() public {
        // Deploy mocks
        mockWeth = address(new MockWETH());
        initialRouter = new MockRouter(mockWeth);

        // Fund owner for service payment
        uint256 servicePayment = 1 ether;
        vm.deal(owner, servicePayment);

        // Deploy token with initial router
        vm.prank(owner);
        token = new Mobsterblox{value: servicePayment}(
            "Mobsterblox", 
            "MB", 
            18, 
            1000000000, 
            5, 
            5, 
            2, 
            address(initialRouter), 
            address(0), 
            owner, 
            serviceAddress
        );
    }

    function testMaliciousRouterChange() public {
        console.log("--- BEFORE-Trigger Router Address ---");
        address originalRouter = address(token.uniswapV2Router());
        console.log("Initial Router:", originalRouter);
        
        vm.startPrank(owner);
        
        // Deploy malicious router
        MockRouter maliciousRouter = new MockRouter(mockWeth);
        console.log("Malicious Router:", address(maliciousRouter));
        
        console.log("--- Trigger Router Change ---");
        // Set new router without validation
        token.setRouterAddress(address(maliciousRouter));
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Router Address ---");
        address currentRouter = address(token.uniswapV2Router());
        console.log("Current Router:", currentRouter);
        
        if (currentRouter == address(maliciousRouter)) {
            console.log("Vulnerability Exists: Router changed to arbitrary address");
        } else {
            console.log("Vulnerability not Exist: Failed to change router");
        }
    }

    function testDangerousLiquidityThreshold() public {
        console.log("--- BEFORE-Trigger Liquidity Threshold ---");
        uint256 initialThreshold = token.numTokensSellToAddToLiquidity();
        console.log("Initial Threshold:", initialThreshold);
        
        vm.startPrank(owner);
        
        console.log("--- Trigger Set MAX_THRESHOLD ---");
        // Set liquidity threshold to max uint value
        token.setNumTokensSellToAddToLiquidity(MAX_UINT);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Liquidity Threshold ---");
        uint256 finalThreshold = token.numTokensSellToAddToLiquidity();
        console.log("Final Threshold:", finalThreshold);
        
        if (finalThreshold == MAX_UINT) {
            console.log("Vulnerability Exists: Threshold set to dangerous MAX_UINT");
        } else {
            console.log("Vulnerability not Exist: Threshold remains safe");
        }
    }
}