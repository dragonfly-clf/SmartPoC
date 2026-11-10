// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TravelCoin.sol";

contract TravelCoinPrivilegeTest is Test {
    TravelCoin public token;
    address owner = address(0x1);
    address constant MOCK_WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant REAL_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address mockPair = address(0x1234);

    function setUp() public {
        // Mock router factory call
        vm.mockCall(
            REAL_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(this)) 
        );
        
        // Mock WETH call
        vm.mockCall(
            REAL_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock createPair call
        vm.mockCall(
            address(this),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        vm.prank(owner);
        token = new TravelCoin();
    }
    
    function createPair(address, address) external returns (address) {
        return mockPair;
    }

    function test_SetBuybackUpperLimitArbitrarily() public {
        console.log("--- BEFORE-TRIGGER ---");
        console.log(
            "Testing buybackUpperLimit: Attempting to set min(0) and max safe value"
        );
        
        console.log("--- TRIGGER START ---");
        vm.startPrank(owner);
        uint maxSafeValue = type(uint256).max / 1e18;
        bool success1;
        bool success2;
        bytes memory reason1;
        bytes memory reason2;
        
        try token.setBuybackUpperLimit(0) {
            success1 = true;
        } catch (bytes memory _reason) {
            success1 = false;
            reason1 = _reason;
        }

        try token.setBuybackUpperLimit(maxSafeValue) {
            success2 = true;
        } catch (bytes memory _reason) {
            success2 = false;
            reason2 = _reason;
        }
        vm.stopPrank();
        console.log("--- TRIGGER END ---");
        
        console.log("--- RESULT VERDICT ---");
        if (success1 && success2) {
            console.log(
                "Vulnerability Exists: Owner can set arbitrary buybackUpperLimit"
            );
        } else {
            if (!success1) 
                console.log("setBuybackUpperLimit(0) reverted:", string(reason1));
            if (!success2) 
                console.log("setBuybackUpperLimit(max) reverted:", string(reason2));
            console.log(
                "Vulnerability not Exist: buybackUpperLimit changes restricted"
            );
        }
    }

    function test_SetMinBalanceForBuybackArbitrarily() public {
        console.log("--- BEFORE-TRIGGER ---");
        console.log(
            "Testing minBalanceBuyback: Attempting to set min(0) and max(uint256)"
        );
        
        console.log("--- TRIGGER START ---");
        vm.startPrank(owner);
        bool success1;
        bool success2;
        bytes memory reason1;
        bytes memory reason2;
        
        try token.setMinBalanceForBuyback(0) {
            success1 = true;
        } catch (bytes memory _reason) {
            success1 = false;
            reason1 = _reason;
        }

        try token.setMinBalanceForBuyback(type(uint256).max) {
            success2 = true;
        } catch (bytes memory _reason) {
            success2 = false;
            reason2 = _reason;
        }
        vm.stopPrank();
        console.log("--- TRIGGER END ---");
        
        console.log("--- RESULT VERDICT ---");
        if (success1 && success2) {
            console.log(
                "Vulnerability Exists: Owner can set arbitrary minBalanceForBuyback"
            );
        } else {
            if (!success1) 
                console.log("setMinBalanceForBuyback(0) reverted:", string(reason1));
            if (!success2) 
                console.log("setMinBalanceForBuyback(max) reverted:", string(reason2));
            console.log(
                "Vulnerability not Exist: minBalanceForBuyback changes restricted"
            );
        }
    }

    function test_SetBuybackFactorArbitrarily() public {
        console.log("--- BEFORE-TRIGGER ---");
        console.log(
            "Testing buybackFactor: Attempting to set 0%% and 1000%%"
        );
        
        console.log("--- TRIGGER START ---");
        vm.startPrank(owner);
        bool success1;
        bool success2;
        bytes memory reason1;
        bytes memory reason2;
        
        try token.setBuybackFactor(0) {
            success1 = true;
        } catch (bytes memory _reason) {
            success1 = false;
            reason1 = _reason;
        }

        try token.setBuybackFactor(1000) {
            success2 = true;
        } catch (bytes memory _reason) {
            success2 = false;
            reason2 = _reason;
        }
        vm.stopPrank();
        console.log("--- TRIGGER END ---");
        
        console.log("--- RESULT VERDICT ---");
        if (success1 && success2) {
            console.log(
                "Vulnerability Exists: Owner can set arbitrary buybackFactor"
            );
        } else {
            if (!success1) 
                console.log("setBuybackFactor(0) reverted:", string(reason1));
            if (!success2) 
                console.log("setBuybackFactor(1000) reverted:", string(reason2));
            console.log(
                "Vulnerability not Exist: buybackFactor changes restricted"
            );
        }
    }
}