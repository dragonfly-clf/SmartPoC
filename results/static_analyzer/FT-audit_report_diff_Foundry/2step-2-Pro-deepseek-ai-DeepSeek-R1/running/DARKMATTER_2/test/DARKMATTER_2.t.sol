// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DARKMATTER.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123abc);
    }
}

contract MockUniswapV2Router {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract DARKMATTERFeeTest is Test {
    DARKMATTER token;
    MockUniswapV2Factory mockFactory;
    MockUniswapV2Router mockRouter;
    address constant mockWETH = address(0x456def);
    address constant busdAddress = address(0x111222);

    function setUp() public {
        mockFactory = new MockUniswapV2Factory();
        mockRouter = new MockUniswapV2Router(address(mockFactory), mockWETH);
        token = new DARKMATTER(address(mockRouter), busdAddress);
    }

    function testFeeManipulationAbove25Percent() public {
        console.log("--- BEFORE-Trigger totalFees ---");
        // Query initial total fees
        uint256 totalFeesBefore = token.totalFees();
        console.log("Initial totalFees:", totalFeesBefore);

        console.log("--- Trigger setFees ---");
        // Set fees exceeding 25% (10% tax + 10% liquidity + 5% marketing + 2% burn = 27%)
        token.setFees(10, 10, 5, 2);
        
        console.log("--- AFTER-Trigger totalFees ---");
        // Query new total fees after manipulation
        uint256 totalFeesAfter = token.totalFees();
        console.log("Manipulated totalFees:", totalFeesAfter);

        // Comparison verdict
        bool vulnerabilityExists = (totalFeesAfter == 27) && (totalFeesAfter > 25);
        console.log("Vulnerability state change:", vulnerabilityExists 
            ? "SUCCESS (Fees updated to 27 and exceeded 25% limit)" 
            : "FAILED (Fees not updated as expected)");

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: setFees allowed fees above 25% limit");
        } else {
            console.log("Vulnerability not Exist: setFees enforced 25% fee limit correctly");
        }
    }
}