// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PPIG.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract MockRouter {
    address public factory;
    // Renamed constant to avoid conflict
    address private constant _WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function WETH() external pure returns (address) {
        return _WETH;
    }
}

contract PPIGFeeTest is Test {
    PPIG token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Fee state structure
    struct FeeState {
        uint256 marketing;
        uint256 burn;
        uint256 total;
    }

    function setUp() public {
        // Deploy mock factory
        MockFactory mockFactory = new MockFactory();
        address mockFactoryAddr = address(mockFactory);

        // Deploy mock router template to get bytecode
        MockRouter mockRouterTemplate = new MockRouter();
        bytes memory runtimeCode = address(mockRouterTemplate).code;
        vm.etch(ROUTER_ADDRESS, runtimeCode);

        // Set storage slot 0 (factory) for router
        vm.store(
            ROUTER_ADDRESS,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(mockFactoryAddr)))
        );

        // Deploy token contract
        token = new PPIG();
    }

    // Helper to get current fee state
    function _getFeeState() internal view returns (FeeState memory) {
        return FeeState({
            marketing: token.sellMarketingFee(),
            burn: token.sellBurnFee(),
            total: token.totalTaxIfSelling()
        });
    }

    function testFeeManipulation() public {
        bool vulnerable = false;

        // Test valid fee combinations (<=50%)
        vm.startPrank(token.owner());
        
        // First valid pair: (50, 0)
        FeeState memory initialState = _getFeeState();
        console.log("--- BEFORE-Trigger setsellTaxes(50,0) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            initialState.marketing, initialState.burn, initialState.total);
        
        console.log("--- Trigger setsellTaxes(50,0) ---");
        token.setsellTaxes(50, 0);
        
        FeeState memory currentState = _getFeeState();
        console.log("--- AFTER-Trigger setsellTaxes(50,0) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            currentState.marketing, currentState.burn, currentState.total);
        
        // Second valid pair: (0,50)
        FeeState memory stateBefore = _getFeeState();
        console.log("\n--- BEFORE-Trigger setsellTaxes(0,50) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            stateBefore.marketing, stateBefore.burn, stateBefore.total);
        
        console.log("--- Trigger setsellTaxes(0,50) ---");
        token.setsellTaxes(0, 50);
        
        currentState = _getFeeState();
        console.log("--- AFTER-Trigger setsellTaxes(0,50) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            currentState.marketing, currentState.burn, currentState.total);
        
        // Third valid pair: (25,25)
        stateBefore = _getFeeState();
        console.log("\n--- BEFORE-Trigger setsellTaxes(25,25) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            stateBefore.marketing, stateBefore.burn, stateBefore.total);
        
        console.log("--- Trigger setsellTaxes(25,25) ---");
        token.setsellTaxes(25, 25);
        
        currentState = _getFeeState();
        console.log("--- AFTER-Trigger setsellTaxes(25,25) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            currentState.marketing, currentState.burn, currentState.total);

        // Test exceeding 50% limit reverts
        stateBefore = _getFeeState();
        console.log("\n--- BEFORE-Trigger EXCEED LIMIT setsellTaxes(51,0) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            stateBefore.marketing, stateBefore.burn, stateBefore.total);
        
        console.log("--- Trigger REVERTING setsellTaxes(51,0) ---");
        vm.expectRevert("Max sell fee under 50%");
        token.setsellTaxes(51,0);
        
        currentState = _getFeeState();
        console.log("--- AFTER-Trigger setsellTaxes(51,0) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            currentState.marketing, currentState.burn, currentState.total);
        
        // Check for unexpected state change
        if (stateBefore.marketing != currentState.marketing || 
            stateBefore.burn != currentState.burn || 
            stateBefore.total != currentState.total) {
            console.log("Verdict: STATE CHANGED after invalid call!");
            vulnerable = true;
        } else {
            console.log("Verdict: State unchanged after revert");
        }

        // Second invalid call: (0,51)
        stateBefore = _getFeeState();
        console.log("\n--- BEFORE-Trigger EXCEED LIMIT setsellTaxes(0,51) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            stateBefore.marketing, stateBefore.burn, stateBefore.total);
        
        console.log("--- Trigger REVERTING setsellTaxes(0,51) ---");
        vm.expectRevert("Max sell fee under 50%");
        token.setsellTaxes(0,51);
        
        currentState = _getFeeState();
        console.log("--- AFTER-Trigger setsellTaxes(0,51) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            currentState.marketing, currentState.burn, currentState.total);
        
        // Check for unexpected state change
        if (stateBefore.marketing != currentState.marketing || 
            stateBefore.burn != currentState.burn || 
            stateBefore.total != currentState.total) {
            console.log("Verdict: STATE CHANGED after invalid call!");
            vulnerable = true;
        } else {
            console.log("Verdict: State unchanged after revert");
        }

        // Third invalid call: (30,21)
        stateBefore = _getFeeState();
        console.log("\n--- BEFORE-Trigger EXCEED LIMIT setsellTaxes(30,21) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            stateBefore.marketing, stateBefore.burn, stateBefore.total);
        
        console.log("--- Trigger REVERTING setsellTaxes(30,21) ---");
        vm.expectRevert("Max sell fee under 50%");
        token.setsellTaxes(30,21);
        
        currentState = _getFeeState();
        console.log("--- AFTER-Trigger setsellTaxes(30,21) ---");
        console.log("FeeState: Marketing=%s Burn=%s Total=%s", 
            currentState.marketing, currentState.burn, currentState.total);
        
        // Check for unexpected state change
        if (stateBefore.marketing != currentState.marketing || 
            stateBefore.burn != currentState.burn || 
            stateBefore.total != currentState.total) {
            console.log("Verdict: STATE CHANGED after invalid call!");
            vulnerable = true;
        } else {
            console.log("Verdict: State unchanged after revert");
        }
        
        vm.stopPrank();

        // Final vulnerability verdict
        if (vulnerable) {
            console.log("Vulnerability Exists: State changed during invalid setsellTaxes calls");
        } else {
            console.log("Vulnerability not Exist: No state changes during invalid setsellTaxes calls");
        }
    }
}