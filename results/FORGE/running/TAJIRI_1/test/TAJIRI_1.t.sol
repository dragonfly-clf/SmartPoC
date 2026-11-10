// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TAJIRI.sol";

contract MockWETH {
    // Empty contract for WETH simulation
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x12345); // Return arbitrary non-zero address
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract TAJIRIGasTest is Test {
    TAJIRI public token;
    address public owner;
    address[] public users;

    function setUp() public {
        owner = address(this);
        
        // Deploy minimal mock contracts
        address weth = address(new MockWETH());
        address factory = address(new MockUniswapV2Factory());
        MockUniswapV2Router router = new MockUniswapV2Router(factory, weth);
        
        // Mock PancakeSwap router address
        address PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(PANCAKE_ROUTER, address(router).code);
        
        // Deploy token contract
        token = new TAJIRI();
    }

    function testIncludeInRewardGasVulnerability() public {
        // Create test accounts (400 accounts for O(n) demonstration)
        console.log("--- BEFORE-Trigger Setup ---");
        console.log("Preparing 400 excluded accounts...");
        
        users = new address[](400);
        for (uint256 i = 0; i < users.length; i++) {
            users[i] = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
            token.excludeFromReward(users[i]);
        }

        console.log("--- Trigger Operation: includeInReward ---");
        uint256 gasBefore = gasleft();
        token.includeInReward(users[users.length - 1]);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("--- AFTER-Trigger Gas Measurement ---");
        console.log("Gas used for includeInReward:", gasUsed);
        
        bool vulnerabilityExists = gasUsed > 250_000;
        console.log("Vulnerability Exists:", vulnerabilityExists ? "YES" : "NO");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: High gas consumption in includeInReward due to O(n) complexity");
        } else {
            console.log("Vulnerability not Exist: Gas consumption within acceptable limits");
        }
        assertGt(gasUsed, 250_000, "Gas usage low - vulnerability not triggered");
    }

    function testGetCurrentSupplyGasVulnerability() public {
        // Create test accounts (500 accounts for O(n) demonstration)
        console.log("--- BEFORE-Trigger Setup ---");
        console.log("Preparing 500 excluded accounts...");
        
        users = new address[](500);
        for (uint256 i = 0; i < users.length; i++) {
            users[i] = address(uint160(uint256(keccak256(abi.encodePacked(i)))));
            token.excludeFromReward(users[i]);
        }

        console.log("--- Trigger Operation: balanceOf (calls _getCurrentSupply) ---");
        uint256 gasBefore = gasleft();
        token.balanceOf(owner);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("--- AFTER-Trigger Gas Measurement ---");
        console.log("Gas used for _getCurrentSupply:", gasUsed);
        
        bool vulnerabilityExists = gasUsed > 2_000_000;
        console.log("Vulnerability Exists:", vulnerabilityExists ? "YES" : "NO");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: High gas consumption in _getCurrentSupply due to O(n) complexity");
        } else {
            console.log("Vulnerability not Exist: Gas consumption within acceptable limits");
        }
        assertGt(gasUsed, 2_000_000, "Gas usage low - vulnerability not triggered");
    }
}