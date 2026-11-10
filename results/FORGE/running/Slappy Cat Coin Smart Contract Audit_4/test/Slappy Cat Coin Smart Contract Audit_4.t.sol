// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SlappyCat.sol";

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockRouter {
    address public factory;
    address public immutable WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor(address _factory) {
        factory = _factory;
    }
}

contract MockPair {}

contract SlappyCatTest is Test {
    SlappyCat token;
    address owner = address(0xA);
    address constant BSC_TESTNET_ROUTER = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    MockFactory factory;
    address lastExcludedUser; // Will be placed at end of exclusion array
    uint256 immutable INITIAL_EXCLUDED_COUNT = 551; // 550 + last excluded user

    function setUp() public {
        // Setup chain ID
        vm.chainId(97); // BSC testnet
        
        // Setup mock Uniswap
        factory = new MockFactory();
        MockRouter realMockRouter = new MockRouter(address(factory));
        vm.etch(BSC_TESTNET_ROUTER, address(realMockRouter).code);
        vm.store(BSC_TESTNET_ROUTER, bytes32(0), bytes32(uint256(uint160(address(factory)))));
        
        // Deploy token
        vm.startPrank(owner);
        token = new SlappyCat();
        
        // Exclude large number of accounts (550)
        lastExcludedUser = makeAddr("LAST_USER");
        populateExclusionList(550);
        
        vm.stopPrank();
    }
    
    function populateExclusionList(uint256 count) private {
        // Exclude test accounts
        for (uint160 i = 0; i < count; i++) {
            address user = address(uint160(1000 + i));
            token.excludeFromReward(user);
        }
        // Exclude last user now to place at end of array
        token.excludeFromReward(lastExcludedUser);
    }

    function testGasCostForLateArrayRemoval() public {
        console.log("--- BEFORE-Trigger State ---");
        // Initial state validation showing user is excluded
        bool isExcludedBefore = token.isExcludedFromReward(lastExcludedUser);
        console.log("User exclusion status: %s", isExcludedBefore ? "Excluded" : "Included");
        assertTrue(isExcludedBefore, "User should be excluded at start");
        console.log("Excluded users count: %d (set in test)", INITIAL_EXCLUDED_COUNT);
        
        // Perform critical operation and measure gas
        console.log("\n--- Trigger Operation ---");
        console.log("Triggering removal of last excluded user...");
        vm.prank(owner);
        uint256 gasStart = gasleft();
        token.includeInReward(lastExcludedUser);
        uint256 gasUsed = gasStart - gasleft();
        
        console.log("\n--- AFTER-Trigger State ---");
        // Verify state change after operation
        bool isExcludedAfter = token.isExcludedFromReward(lastExcludedUser);
        console.log("User exclusion status: %s", isExcludedAfter ? "Excluded" : "Included");
        assertFalse(isExcludedAfter, "User should be included after removal");
        console.log("Excluded users count: %d (calculated)", INITIAL_EXCLUDED_COUNT - 1);
        
        // Log and analyze gas consumption
        console.log("\n--- Gas Analysis ---");
        console.log("Gas used for operation: %d units", gasUsed);
        console.log("Array size during operation: %d elements", INITIAL_EXCLUDED_COUNT);
        
        // Final vulnerability verdict based on gas usage
        console.log("\n--- Vulnerability Verdict ---");
        if (gasUsed > 500_000) {
            console.log("Vulnerability Exists: Gas consumption exceeds safe threshold (500k gas) for large array operation");
        } else {
            console.log("Vulnerability not Exist: Gas consumption within acceptable limits");
        }
    }
}