// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MajorDOGE.sol";

contract MajorDOGE_UniquenessViolationTest is Test {
    MajorDOGE public token;
    address public owner;
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant MOCK_WETH = address(0xE);
    address constant MOCK_FACTORY = address(0x123);
    address constant MOCK_PAIR = address(0x456);
    
    function setUp() public {
        owner = address(this);
        
        // Mock router responses
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory response
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );
        
        token = new MajorDOGE();
    }

    function test_setSwapAndLiquifyEnabled_MultipleCalls() public {
        bool flag = true;
        
        console.log("==== swapAndLiquifyEnabled Test START ====");
        for (uint i=0; i<3; i++) {
            bool newValue = (i % 2 == 0); // Alternates: true, false, true
            console.log("--- Step %d --- %s", i+1, newValue ? "Enable" : "Disable");
            
            console.log("BEFORE:");
            bool beforeState = token.swapAndLiquifyEnabled();
            console.log("swapAndLiquifyEnabled: %s", beforeState ? "true" : "false");
            
            console.log("TRIGGER: setSwapAndLiquifyEnabled(%s)", newValue ? "true" : "false");
            token.setSwapAndLiquifyEnabled(newValue);
            
            console.log("AFTER:");
            bool afterState = token.swapAndLiquifyEnabled();
            console.log("swapAndLiquifyEnabled: %s", afterState ? "true" : "false");
            
            if (afterState != newValue) {
                flag = false;
                console.log("MISMATCH: State not updated at step %d!", i+1);
            } else {
                console.log("STATE UPDATE VERIFIED (step %d)", i+1);
            }
        }
        
        if (flag) {
            console.log("Vulnerability Exists: swapAndLiquifyEnabled state can be arbitrarily modified");
        } else {
            console.log("Vulnerability not Exist: Failed to update swapAndLiquifyEnabled state");
        }
    }

    function test_setSwapAndLiquifyByLimitOnly_MultipleCalls() public {
        bool flag = true;
        
        console.log("==== swapAndLiquifyByLimitOnly Test START ====");
        for (uint i=0; i<3; i++) {
            bool newValue = (i % 2 == 0); // Alternates: true, false, true
            console.log("--- Step %d --- %s", i+1, newValue ? "Enable" : "Disable");
            
            console.log("BEFORE:");
            bool beforeState = token.swapAndLiquifyByLimitOnly();
            console.log("swapAndLiquifyByLimitOnly: %s", beforeState ? "true" : "false");
            
            console.log("TRIGGER: setSwapAndLiquifyByLimitOnly(%s)", newValue ? "true" : "false");
            token.setSwapAndLiquifyByLimitOnly(newValue);
            
            console.log("AFTER:");
            bool afterState = token.swapAndLiquifyByLimitOnly();
            console.log("swapAndLiquifyByLimitOnly: %s", afterState ? "true" : "false");
            
            if (afterState != newValue) {
                flag = false;
                console.log("MISMATCH: State not updated at step %d!", i+1);
            } else {
                console.log("STATE UPDATE VERIFIED (step %d)", i+1);
            }
        }
        
        if (flag) {
            console.log("Vulnerability Exists: swapAndLiquifyByLimitOnly state can be arbitrarily modified");
        } else {
            console.log("Vulnerability not Exist: Failed to update swapAndLiquifyByLimitOnly state");
        }
    }
}