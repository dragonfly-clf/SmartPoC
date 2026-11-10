// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GMTdoge.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdead);
    }
}

contract MockRouter {
    address immutable private factoryAddr;

    constructor(address _factoryAddr) {
        factoryAddr = _factoryAddr;
    }

    function factory() external view returns (address) {
        return factoryAddr;
    }
}

contract PrivilegeEscalationTest is Test {
    GMTdoge token;
    address attacker = makeAddr("attacker");
    uint256 initialSupply;

    function setUp() public {
        // Deploy mock factory
        MockFactory mockFactory = new MockFactory();
        
        // Deploy mock router using mock factory address
        MockRouter deployedMockRouter = new MockRouter(address(mockFactory));
        
        // Set up the hardcoded router address to use the mock implementation
        address fakeRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(fakeRouterAddr, address(deployedMockRouter).code);

        // Deploy the token contract
        token = new GMTdoge();
        initialSupply = token.totalSupply();
    }

    function test_unauthorized_setSwapBackSettings() public {
        console.log("--- BEFORE-Trigger Call ---");
        console.log("Expected behavior: Should revert !AUTHORIZED on unauthorized access");

        console.log("--- Trigger Unauthorized Call (setSwapBackSettings) ---");
        bool success;
        bytes memory returnData;
        try this.externalCall_setSwapBackSettings() {
            success = true;
        } catch (bytes memory reason) {
            returnData = reason;
        }

        console.log("--- AFTER-Trigger State ---");
        if (success) {
            console.log("ATTACK SUCCESS: Unauthorized setSwapBackSettings completed");
            console.log("Vulnerability Exists: Authorization bypassed in setSwapBackSettings");
        } else {
            console.log("Authorization Check PASSED: Call reverted");
            if (returnData.length > 0) {
                console.log("Revert reason:", string(returnData));
            }
            console.log("Vulnerability not Exist: Authorization enforced in setSwapBackSettings");
        }
    }

    function externalCall_setSwapBackSettings() external {
        vm.prank(attacker);
        token.setSwapBackSettings(true, 100);
    }

    function test_unauthorized_setTxLimit() public {
        console.log("--- BEFORE-Trigger Call ---");
        console.log("Expected behavior: Should revert !AUTHORIZED on unauthorized access");

        console.log("--- Trigger Unauthorized Call (setTxLimit) ---");
        uint256 minLimit = initialSupply / 10000;
        bool success;
        bytes memory returnData;
        try this.externalCall_setTxLimit(minLimit) {
            success = true;
        } catch (bytes memory reason) {
            returnData = reason;
        }

        console.log("--- AFTER-Trigger State ---");
        if (success) {
            console.log("ATTACK SUCCESS: Unauthorized setTxLimit completed");
            console.log("Vulnerability Exists: Authorization bypassed in setTxLimit");
        } else {
            console.log("Authorization Check PASSED: Call reverted");
            if (returnData.length > 0) {
                console.log("Revert reason:", string(returnData));
            }
            console.log("Vulnerability not Exist: Authorization enforced in setTxLimit");
        }
    }

    function externalCall_setTxLimit(uint256 limit) external {
        vm.prank(attacker);
        token.setTxLimit(limit);
    }

    function test_unauthorized_setBuybackMultiplierSettings() public {
        console.log("--- BEFORE-Trigger Call ---");
        console.log("Expected behavior: Should revert !AUTHORIZED on unauthorized access");

        console.log("--- Trigger Unauthorized Call (setBuybackMultiplierSettings) ---");
        bool success;
        bytes memory returnData;
        try this.externalCall_setBuybackMultiplierSettings() {
            success = true;
        } catch (bytes memory reason) {
            returnData = reason;
        }

        console.log("--- AFTER-Trigger State ---");
        if (success) {
            console.log("ATTACK SUCCESS: Unauthorized multiplier settings change");
            console.log("Vulnerability Exists: Authorization bypassed in setBuybackMultiplierSettings");
        } else {
            console.log("Authorization Check PASSED: Call reverted");
            if (returnData.length > 0) {
                console.log("Revert reason:", string(returnData));
            }
            console.log("Vulnerability not Exist: Authorization enforced in setBuybackMultiplierSettings");
        }
    }

    function externalCall_setBuybackMultiplierSettings() external {
        vm.prank(attacker);
        token.setBuybackMultiplierSettings(3, 1, 1);
    }

    function test_unauthorized_setDistributionCriteria() public {
        console.log("--- BEFORE-Trigger Call ---");
        console.log("Expected behavior: Should revert !AUTHORIZED on unauthorized access");

        console.log("--- Trigger Unauthorized Call (setDistributionCriteria) ---");
        bool success;
        bytes memory returnData;
        try this.externalCall_setDistributionCriteria() {
            success = true;
        } catch (bytes memory reason) {
            returnData = reason;
        }

        console.log("--- AFTER-Trigger State ---");
        if (success) {
            console.log("ATTACK SUCCESS: Unauthorized distribution criteria change");
            console.log("Vulnerability Exists: Authorization bypassed in setDistributionCriteria");
        } else {
            console.log("Authorization Check PASSED: Call reverted");
            if (returnData.length > 0) {
                console.log("Revert reason:", string(returnData));
            }
            console.log("Vulnerability not Exist: Authorization enforced in setDistributionCriteria");
        }
    }

    function externalCall_setDistributionCriteria() external {
        vm.prank(attacker);
        token.setDistributionCriteria(1, 1);
    }
}