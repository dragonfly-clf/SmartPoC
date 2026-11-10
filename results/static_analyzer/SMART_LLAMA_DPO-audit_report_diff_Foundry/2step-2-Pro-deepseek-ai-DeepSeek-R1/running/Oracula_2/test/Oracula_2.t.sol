// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Oracula.sol";

contract MockFactory {
    address public createPairResult;
    
    function setCreatePairResult(address _result) public {
        createPairResult = _result;
    }
    
    function createPair(address, address) external returns (address) {
        return createPairResult;
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
}

contract OraculaTest is Test {
    Oracula token;
    address devAddress = address(0x1000);
    address rewardAddress = address(0x2000);
    address mockPair = address(0x5000);
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockWETH = address(0x2222);
    address mockFactory = address(0x3333);
    address initPair = address(0xCAFE);

    function setUp() public {
        // Setup mock factory with createPair result
        MockFactory mockFactoryImpl = new MockFactory();
        mockFactoryImpl.setCreatePairResult(initPair);
        vm.etch(mockFactory, address(mockFactoryImpl).code);

        // Setup mock router at hardcoded address
        MockRouter mockRouterImpl = new MockRouter();
        vm.etch(HARDCODED_ROUTER, address(mockRouterImpl).code);

        // Set storage for factory and WETH in mock router
        vm.store(HARDCODED_ROUTER, bytes32(uint256(0)), bytes32(uint256(uint160(mockFactory))));
        vm.store(HARDCODED_ROUTER, bytes32(uint256(1)), bytes32(uint256(uint160(mockWETH))));

        // Deploy token with parameters
        token = new Oracula(
            devAddress,
            rewardAddress,
            1,  // burnFee
            1,  // devFee
            1   // rewardFee
        );
    }

    function test_DuplicatePairSettingReverts() public {
        address owner = token.owner();
        vm.startPrank(owner);
        
        // First enable should succeed
        token.setAutomatedMarketMakerPair(mockPair, true);
        assertTrue(token.exchangePairs(mockPair), "Pair should be enabled");

        // Attempt to re-enable should revert
        vm.expectRevert("MemeKing: Automated market maker pair is already set to that value");
        token.setAutomatedMarketMakerPair(mockPair, true);

        // Disable the pair
        token.setAutomatedMarketMakerPair(mockPair, false);
        assertFalse(token.exchangePairs(mockPair), "Pair should be disabled");

        // Attempt to re-disable should revert
        vm.expectRevert("MemeKing: Automated market maker pair is already set to that value");
        token.setAutomatedMarketMakerPair(mockPair, false);
        
        vm.stopPrank();
    }

    function test_CorrectPairStatusUpdates() public {
        address owner = token.owner();
        vm.startPrank(owner);
        
        console2.log("--- BEFORE-Trigger SetPair (Initial) ---");
        bool initialPairStatus = token.exchangePairs(mockPair);
        console2.log("Initial pair status (false expected):", initialPairStatus);
        assertFalse(initialPairStatus, "Initial state should be disabled");
        
        console2.log("--- Trigger: Enable AMM Pair ---");
        token.setAutomatedMarketMakerPair(mockPair, true);

        console2.log("--- AFTER-Trigger SetPair (Enabled) ---");
        bool enabledPairStatus = token.exchangePairs(mockPair);
        console2.log("Enabled pair status (true expected):", enabledPairStatus);
        assertTrue(enabledPairStatus, "Pair should be enabled after enabling");
        
        if (initialPairStatus != enabledPairStatus) {
            console2.log("Verification: State changed successfully! (Initial: false -> After: true)");
        } else {
            console2.log("Verification: State did not change as expected!");
        }
        
        console2.log("\n--- BEFORE-Trigger SetPair (Before Disable) ---");
        bool beforeDisableStatus = token.exchangePairs(mockPair);
        console2.log("Pair status before disable (true expected):", beforeDisableStatus);
        assertTrue(beforeDisableStatus, "Should be enabled before disabling");
        
        console2.log("--- Trigger: Disable AMM Pair ---");
        token.setAutomatedMarketMakerPair(mockPair, false);

        console2.log("--- AFTER-Trigger SetPair (Disabled) ---");
        bool disabledPairStatus = token.exchangePairs(mockPair);
        console2.log("Disabled pair status (false expected):", disabledPairStatus);
        assertFalse(disabledPairStatus, "Pair should be disabled after disabling");
        
        if (beforeDisableStatus != disabledPairStatus) {
            console2.log("Verification: State changed successfully! (Before: true -> After: false)");
        } else {
            console2.log("Verification: State did not change as expected!");
        }
        
        console2.log("\n--- BEFORE-Trigger SetPair (Before Re-enable) ---");
        bool beforeReenableStatus = token.exchangePairs(mockPair);
        console2.log("Pair status before re-enable (false expected):", beforeReenableStatus);
        assertFalse(beforeReenableStatus, "Should be disabled before re-enabling");
        
        console2.log("--- Trigger: Re-enable AMM Pair ---");
        token.setAutomatedMarketMakerPair(mockPair, true);

        console2.log("--- AFTER-Trigger SetPair (Re-enabled) ---");
        bool reenabledPairStatus = token.exchangePairs(mockPair);
        console2.log("Re-enabled pair status (true expected):", reenabledPairStatus);
        assertTrue(reenabledPairStatus, "Pair should be enabled after re-enabling");
        
        if (beforeReenableStatus != reenabledPairStatus) {
            console2.log("Verification: State changed successfully! (Before: false -> After: true)");
        } else {
            console2.log("Verification: State did not change as expected!");
        }
        
        vm.stopPrank();
        console2.log("\nVulnerability not Exist: AMM pair status changes correctly, demonstrating expected protocol behavior");
    }
}