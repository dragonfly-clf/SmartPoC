// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BLACKBEARD_INU.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1); // Dummy pair address
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xCAFE);
    }
    
    function WETH() external pure returns (address) {
        return address(0xBEEF);
    }
}

contract FeeManipulationTest is Test {
    BLACKBEARD_INU token;
    address owner = address(0xBEEF);
    
    function setUp() public {
        // Deploy mock factory and set code at 0xCAFE
        MockFactory mockFactory = new MockFactory();
        vm.etch(address(0xCAFE), address(mockFactory).code);
        
        // Deploy mock router and set code at the PancakeSwap address
        MockRouter mockRouter = new MockRouter();
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(mockRouter).code);
        
        // Deploy token
        vm.prank(owner);
        token = new BLACKBEARD_INU();
    }

    function testFeeExceedsLimit() public {
        uint256 MAX_ALLOWED_FEE = 25;
        uint256 DENOMINATOR = 100;
        uint256 excessiveFee = MAX_ALLOWED_FEE + 1; // 26%
        
        console.log("--- BEFORE-Trigger ---");
        console.log("Attempting to set token fee to 26% (exceeding 25%% limit)");

        console.log("--- Trigger ---");
        console.log("Calling setFees(26%%, 0, 0, 0, 100) as owner");
        
        bool success;
        vm.startPrank(owner);
        try token.setFees(
            excessiveFee, // liquidityFee (26%)
            0,            // buybackFee
            0,            // reflectionFee
            0,            // marketingFee
            DENOMINATOR   // feeDenominator
        ) {
            success = true;
        } catch {
            success = false;
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        if (success) {
            console.log("Fee set to 26%% successfully without revert");
            console.log("Vulnerability Exists: Owner bypassed MAX_ALLOWED_FEE restriction");
        } else {
            console.log("Fee setting reverted as expected");
            console.log("Vulnerability not Exist: MAX_ALLOWED_FEE restriction enforced");
        }
    }
}