// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MEGADOGE.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MEGADOGETest is Test {
    MEGADOGE token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        // Deploy mock factory and set up router mocks
        address mockFactory = address(new MockUniswapV2Factory());
        
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(WETH)
        );
        
        token = new MEGADOGE();
    }

    function testFeeExceedsLimit() public {
        address owner = token.owner();
        
        // Query total fees BEFORE vulnerability trigger
        console2.log("--- BEFORE-Trigger totalFees ---");
        uint256 totalFeesBefore = token.totalFees();
        console2.log("Total fees before:", totalFeesBefore, "%");

        console2.log("--- Trigger setDOGERewardsFee(20) ---");
        vm.prank(owner);
        token.setDOGERewardsFee(20); // 20% DOGERewardsFee plus existing fees causes total fee >25%

        // Query total fees AFTER vulnerability trigger
        console2.log("--- AFTER-Trigger totalFees ---");
        uint256 totalFeesAfter = token.totalFees();
        console2.log("Total fees after:", totalFeesAfter, "%");
        
        // Differential comparison: Check if total fees exceed 25%
        if (totalFeesAfter > 25) {
            console2.log("Vulnerability Exists: Total fees exceed 25% after fee modification");
        } else {
            console2.log("Vulnerability not Exist: Total fees within 25% limit after modification");
        }
    }
}