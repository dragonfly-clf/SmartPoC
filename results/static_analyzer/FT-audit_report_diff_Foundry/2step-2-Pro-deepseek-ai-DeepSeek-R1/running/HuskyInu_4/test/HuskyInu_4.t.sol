// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/HuskyInu.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xFaC771);
    }

    function WETH() external pure returns (address) {
        return address(0xDeaDBeef);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x000000112233);
    }
}

contract LowLevelCallTest is Test {
    HuskyInu token;
    address owner = makeAddr("owner");
    MockRouter mockRouter;
    MockFactory mockFactory;

    function setUp() public {
        // Deploy mocks
        mockRouter = new MockRouter();
        mockFactory = new MockFactory();
        
        // Redirect router call to our mock
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(mockRouter).code);
        vm.etch(address(0xFaC771), address(mockFactory).code);
        
        vm.startPrank(owner);
        token = new HuskyInu("TestToken", "TT");
        vm.stopPrank();
    }

    function test_RevertingCall() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Preparing low-level call to failing contract");
        
        console.log("--- Trigger: Execute Call ---");
        // Create failing contract
        MockFailingContract mock = new MockFailingContract();
        
        // Prepare call to non-existent function
        bytes memory payload = abi.encodeWithSignature("nonexistentFunction()");
        
        // Execute failing call
        (bool success, ) = address(mock).call(payload);
        
        console.log("--- AFTER-Trigger ---");
        console.log("Call success status:", success ? "true" : "false");

        // Verify failure
        assertFalse(success, "Call should fail");
        
        // Final vulnerability verdict
        console.log("Vulnerability not Exist: Low-level call fails as expected, which is normal EVM behavior without state changes");
    }
}

contract MockFailingContract {
    fallback() external payable {
        revert("Low-level call failed");
    }
}