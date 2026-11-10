// SPDX-License-Identifier: MIT
pragma solidity 0.8.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZOUTBREAK.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
}

contract MockPair {
    function sync() external {}
}

contract MockFactory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouterInitializable {
    address public factory;
    address public WETH;
    
    function initialize(address _factory, address _weth) public {
        factory = _factory;
        WETH = _weth;
    }
}

contract ZOUTBREAKFeeManipulationTest is Test {
    ZOUTBREAK public token;
    address public securityManager = address(0x123);
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock contracts
        MockWETH mockWETH = new MockWETH();
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        
        // Create mock router initialization code
        bytes memory mockRouterCode = type(MockRouterInitializable).runtimeCode;
        
        // Patch PancakeSwap router with mock code
        vm.etch(PANCAKE_ROUTER, mockRouterCode);
        
        // Initialize the mock router
        (bool success, ) = PANCAKE_ROUTER.call(
            abi.encodeWithSignature("initialize(address,address)", address(mockFactory), address(mockWETH))
        );
        require(success, "Router initialization failed");

        // Deploy token contract after router setup
        token = new ZOUTBREAK();
        
        // Add security manager
        token.F28__Add_Security_Manager(securityManager);
    }

    function testFeeManipulationOver25Percent() public {
        // Enable price impact1 feature (required for fee setting)
        vm.prank(securityManager);
        token.F08__Set_Sell_Price_Impact1__Multiplied_by_100(1000); // Set to 10%

        console.log("--- BEFORE-Trigger Fees ---");
        // Query current fees for above impact1
        uint256 projFeeAboveBefore;
        uint256 reflFeeAboveBefore;
        (, , projFeeAboveBefore, reflFeeAboveBefore, ) = token.A08__Price_Impact1__Sell_Fees_Actual_Percentage();
        console.log("ProjectFeeAboveImpact1 (before): ", projFeeAboveBefore);
        console.log("ReflectionsFeeAboveImpact1 (before): ", reflFeeAboveBefore);

        console.log("--- Trigger SetFees ---");
        // Set fees above the 25% threshold
        vm.prank(securityManager);
        token.F12__Set_Fees_For_Sells_With_Price_Impact1(
            20,   // project_fee_under_impact1
            30,   // project_fee_above_impact1 (30% > 25%)
            20,   // reflections_fee_under_impact1
            30    // reflections_fee_above_impact1
        );
        console.log("Called F12__Set_Fees_For_Sells_With_Price_Impact1(20,30,20,30)");

        console.log("--- AFTER-Trigger Fees ---");
        uint256 projFeeAboveAfter;
        uint256 reflFeeAboveAfter;
        (, , projFeeAboveAfter, reflFeeAboveAfter, ) = token.A08__Price_Impact1__Sell_Fees_Actual_Percentage();
        console.log("ProjectFeeAboveImpact1 (after): ", projFeeAboveAfter);
        console.log("ReflectionsFeeAboveImpact1 (after): ", reflFeeAboveAfter);

        console.log("Change Verification:");
        console.log("  ProjectFeeAboveImpact1 changed from", projFeeAboveBefore, "to", projFeeAboveAfter);
        console.log("  ReflectionsFeeAboveImpact1 changed from", reflFeeAboveBefore, "to", reflFeeAboveAfter);

        // Vulnerability exists if ANY fee was set above 25%
        bool vulnerabilityExists = reflFeeAboveAfter > 25;
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Fees above 25% were set successfully");
        } else {
            console.log("Vulnerability not Exist: Fees are within 25% limit");
        }
    }
}