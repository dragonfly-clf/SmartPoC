// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PresidentsSquidGame.sol";

contract MockWETH {}

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
    address public factory;
    address public WETH;
}

contract PresidentsSquidGameTest is Test {
    PresidentsSquidGame token;
    address public constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant MOCK_PAIR = address(0xDEAD);
    
    function setUp() public {
        // Deploy mock contracts
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory(MOCK_PAIR);
        MockRouter mockRouter = new MockRouter();
        
        // Setup mock router at hardcoded address
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.store(
            ROUTER_ADDRESS, 
            bytes32(0), 
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            ROUTER_ADDRESS, 
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(address(mockWETH))))
        );
        
        // Deploy token contract
        token = new PresidentsSquidGame();
    }
    
    function testAMMPairStateInconsistency() public {
        address testPair = makeAddr("testPair");
        
        console.log("--- BEFORE-First SetAMMPair ---");
        console.log("Attempting first pair enable...");
        token.setAutomatedMarketMakerPair(testPair, true);
        console.log("First pair enable: SUCCESS");
        
        console.log("--- Trigger Identical SetAMMPair ---");
        vm.expectRevert("Error: Automated market maker pair is already set to that value");
        token.setAutomatedMarketMakerPair(testPair, true);
        console.log("Second identical enable: REVERTED");
        
        console.log("Vulnerability not Exist: Function reverts correctly for duplicate AMM pair configuration");
    }
    
    function testRewardAddressFeeExclusion() public {
        address newReward1 = makeAddr("newReward1");
        address newReward2 = makeAddr("newReward2");
        
        console.log("--- BEFORE FIRST REWARD SET ---");
        console.log("Initial exclusion status:");
        console.log(" newReward1:", token.isExcludedFromFees(newReward1) ? "EXCLUDED" : "NOT EXCLUDED");
        console.log(" newReward2:", token.isExcludedFromFees(newReward2) ? "EXCLUDED" : "NOT EXCLUDED");

        console.log("--- SET REWARD newReward1 ---");
        token.setRewardAddress(newReward1);
        console.log("AFTER FIRST SET:");
        console.log(" newReward1:", token.isExcludedFromFees(newReward1) ? "EXCLUDED" : "NOT EXCLUDED");
        console.log(" newReward2:", token.isExcludedFromFees(newReward2) ? "EXCLUDED" : "NOT EXCLUDED");
        assertTrue(token.isExcludedFromFees(newReward1), "Reward1 should be excluded");
        
        console.log("\n--- BEFORE SECOND REWARD SET ---");
        console.log("Current exclusion status:");
        console.log(" newReward1:", token.isExcludedFromFees(newReward1) ? "EXCLUDED" : "NOT EXCLUDED");
        console.log(" newReward2:", token.isExcludedFromFees(newReward2) ? "EXCLUDED" : "NOT EXCLUDED");
        
        console.log("--- SET REWARD newReward2 ---");
        token.setRewardAddress(newReward2);
        console.log("AFTER SECOND SET:");
        console.log(" newReward1:", token.isExcludedFromFees(newReward1) ? "EXCLUDED" : "NOT EXCLUDED");
        console.log(" newReward2:", token.isExcludedFromFees(newReward2) ? "EXCLUDED" : "NOT EXCLUDED");
        assertFalse(token.isExcludedFromFees(newReward1), "Reward1 should not be excluded");
        assertTrue(token.isExcludedFromFees(newReward2), "Reward2 should be excluded");
        
        console.log("Vulnerability not Exist: Reward address change correctly updates fee exclusion list");
    }
}