// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Ordo_Chain.sol";

contract TaxPoolDistributeOverflowTest is Test {
    TaxPool taxPool;
    address owner;
    
    // State variable slots (adjust if contract layout differs)
    uint256 constant BALANCE_SLOT = 1;
    uint256 constant MAXPERCENT_SLOT = 2;
    uint256 constant MARKETING_PERCENTAGE_SLOT = 3;
    uint256 constant STAKINGREWARD_PERCENTAGE_SLOT = 4;
    uint256 constant BUYBACKANDBURN_PERCENTAGE_SLOT = 5;

    function setUp() public {
        taxPool = new TaxPool();
        owner = taxPool.owner();
        
        // Configure state to trigger overflow
        vm.startPrank(owner);
        vm.store(address(taxPool), bytes32(MAXPERCENT_SLOT), bytes32(uint256(2)));
        vm.store(address(taxPool), bytes32(MARKETING_PERCENTAGE_SLOT), bytes32(uint256(2)));
        vm.store(address(taxPool), bytes32(STAKINGREWARD_PERCENTAGE_SLOT), bytes32(uint256(0)));
        vm.store(address(taxPool), bytes32(BUYBACKANDBURN_PERCENTAGE_SLOT), bytes32(uint256(0)));
        vm.stopPrank();
    }

    function test_distribute_arithmeticOverflow() public {
        // Set balance to cause overflow
        uint256 overflowAmount = type(uint256).max / 2 + 1;
        vm.store(address(taxPool), bytes32(BALANCE_SLOT), bytes32(overflowAmount));
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 preBalance = uint256(vm.load(address(taxPool), bytes32(BALANCE_SLOT)));
        uint256 preMarketing = uint256(vm.load(address(taxPool), bytes32(MARKETING_PERCENTAGE_SLOT)));
        uint256 preStaking = uint256(vm.load(address(taxPool), bytes32(STAKINGREWARD_PERCENTAGE_SLOT)));
        uint256 preBurn = uint256(vm.load(address(taxPool), bytes32(BUYBACKANDBURN_PERCENTAGE_SLOT)));
        uint256 preMaxPercent = uint256(vm.load(address(taxPool), bytes32(MAXPERCENT_SLOT)));
        
        console.log("Tax balance:", preBalance);
        console.log("Marketing %:", preMarketing);
        console.log("Staking %:", preStaking);
        console.log("Burn %:", preBurn);
        console.log("Max %:", preMaxPercent);
        console.log("Sum %:", preMarketing + preStaking + preBurn);
        
        console.log("--- Trigger Operation: taxPool.distribute() ---");
        bool reverted = false;
        vm.prank(owner);
        try taxPool.distribute() {
            reverted = false;
        } catch {
            reverted = true;
        }

        console.log("--- AFTER-Trigger State ---");
        uint256 postBalance = uint256(vm.load(address(taxPool), bytes32(BALANCE_SLOT)));
        uint256 postMarketing = uint256(vm.load(address(taxPool), bytes32(MARKETING_PERCENTAGE_SLOT)));
        uint256 postStaking = uint256(vm.load(address(taxPool), bytes32(STAKINGREWARD_PERCENTAGE_SLOT)));
        uint256 postBurn = uint256(vm.load(address(taxPool), bytes32(BUYBACKANDBURN_PERCENTAGE_SLOT)));
        uint256 postMaxPercent = uint256(vm.load(address(taxPool), bytes32(MAXPERCENT_SLOT)));
        
        console.log("Tax balance:", postBalance);
        console.log("Marketing %:", postMarketing);
        console.log("Staking %:", postStaking);
        console.log("Burn %:", postBurn);
        console.log("Max %:", postMaxPercent);
        console.log("Sum %:", postMarketing + postStaking + postBurn);
        
        console.log("Vulnerability check results:");
        console.log("- Call reverted?", reverted);
        console.log("- Balance unchanged?", preBalance == postBalance);
        console.log("- Marketing % unchanged?", preMarketing == postMarketing);
        console.log("- Staking % unchanged?", preStaking == postStaking);
        console.log("- Burn % unchanged?", preBurn == postBurn);
        console.log("- Max % unchanged?", preMaxPercent == postMaxPercent);
        
        // Validate unchanged state and revert status
        bool vulnerabilityExists = reverted 
            && preBalance == postBalance
            && preMarketing == postMarketing
            && preStaking == postStaking
            && preBurn == postBurn
            && preMaxPercent == postMaxPercent;
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: arithmetic overflow prevented distribution and maintained all state");
            emit log_string("Vulnerability Exists: arithmetic overflow in distribute()");
        } else {
            console.log("Vulnerability not Exist: state changed unexpectedly or call succeeded");
            emit log_string("Vulnerability not Exist: distribute() executed normally");
        }
    }
}