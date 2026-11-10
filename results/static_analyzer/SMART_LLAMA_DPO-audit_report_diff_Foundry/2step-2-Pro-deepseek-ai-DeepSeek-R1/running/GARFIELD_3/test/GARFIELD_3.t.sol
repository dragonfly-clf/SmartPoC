// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GARFIELD.sol";

contract MockPancakeFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockPancakeRouter {
    MockPancakeFactory public factory;
    
    constructor() public {
        factory = new MockPancakeFactory();
    }

    function WETH() external pure returns (address) {
        return address(0x1);
    }
}

contract GarfieldInconsistentStateTest is Test {
    GARFIELD token;
    MockPancakeRouter public router;
    address payable owner;
    
    function setUp() public {
        router = new MockPancakeRouter();
        token = new GARFIELD(payable(address(router)));
        owner = payable(address(this));
    }
    
    function test_rewardCycleBlocksNotUpdated() public {
        // Activate contract to initialize first state
        token.activateContract();
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialRewardCycleBlock = token.getRewardCycleBlock();
        console.log("Initial reward cycle duration:", initialRewardCycleBlock);
        console.log("Expected: 1 day (86400 seconds)");
        
        console.log("--- Trigger Time Warp (1 week + 1 second) ---");
        uint256 warpDuration = 1 weeks + 1;
        vm.warp(block.timestamp + warpDuration);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 updatedRewardCycleBlock = token.getRewardCycleBlock();
        console.log("Updated reward cycle duration:", updatedRewardCycleBlock);
        console.log("Expected: 7 days (604800 seconds)");
        
        uint256 oneDay = 1 days;
        uint256 sevenDays = 7 days;
        bool vulnerabilityExists = updatedRewardCycleBlock != sevenDays;
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Reward cycle block did not update to 7 days after disable period");
        } else {
            console.log("Vulnerability not Exist: Contract state updated correctly to 7-day cycle");
        }
        
        // Final verdict for test automation
        require(!vulnerabilityExists, "Vulnerability exists");
    }
}