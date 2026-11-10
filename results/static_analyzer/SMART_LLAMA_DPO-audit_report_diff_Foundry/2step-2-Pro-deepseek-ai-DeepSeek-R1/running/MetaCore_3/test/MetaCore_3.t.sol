// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaCore.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}

contract MockRouterFixed {
    function factory() external pure returns (address) {
        return address(0x987654321);
    }

    function WETH() external pure returns (address) {
        return address(0xABCDEF);
    }
}

contract MetaCoreInconsistentStateTest is Test {
    MetaCore public token;
    address owner = address(0x1);
    address marketingWallet = address(0x3);
    
    address constant routerAddress = address(0x123456789);
    address constant factoryAddress = address(0x987654321);
    address constant wethAddress = address(0xABCDEF);
    address constant pairAddress = address(0x789);

    function setUp() public {
        // Deploy mock contracts to fixed addresses
        bytes memory wethCode = type(MockWETH).runtimeCode;
        bytes memory factoryCode = type(MockFactory).runtimeCode;
        bytes memory routerCode = type(MockRouterFixed).runtimeCode;
        
        vm.etch(wethAddress, wethCode);
        vm.etch(factoryAddress, factoryCode);
        vm.etch(routerAddress, routerCode);

        // Deploy token
        vm.startPrank(owner);
        token = new MetaCore(
            marketingWallet,
            1, // stakingReleaseIntervalDays
            routerAddress // uniswapRouter
        );
        
        // Setup token for testing
        token.prepareForPreSale();
        token.afterPreSale();
        token.setSwapAndLiquifyEnabled(true);
        token.setBuyBackEnabled(true);
        token.goLive();
        vm.stopPrank();
    }

    function testStateChangesDuringSwap() public {
        // Verify initial states (state queries before triggering actions)
        console.log("--- BEFORE-Trigger State Capture ---");
        bool initialSwap = token.swapAndLiquifyEnabled();
        bool initialBuyBack = token.buyBackEnabled();
        console.log("Initial swapAndLiquifyEnabled: %s", initialSwap);
        console.log("Initial buyBackEnabled: %s", initialBuyBack);

        // Log the trigger actions
        console.log("--- Trigger: Simulate Lock and Change Flags ---");
        
        // Setting swap lock (inSwap=true)
        bytes32 lockSlot = bytes32(uint256(50));
        vm.store(address(token), lockSlot, bytes32(uint256(1)));

        // Changing states during locked swap
        vm.prank(owner);
        token.setSwapAndLiquifyEnabled(false);
        
        vm.prank(owner);
        token.setBuyBackEnabled(false);
        
        // Post-trigger state capture
        console.log("--- AFTER-Trigger State Capture ---");
        bool finalSwap = token.swapAndLiquifyEnabled();
        bool finalBuyBack = token.buyBackEnabled();
        console.log("Final swapAndLiquifyEnabled: %s", finalSwap);
        console.log("Final buyBackEnabled: %s", finalBuyBack);
        
        // Vulnerability verdict based on state changes
        bool stateChanged = (initialSwap != finalSwap) || (initialBuyBack != finalBuyBack);
        if (stateChanged) {
            console.log("Vulnerability Exists: State variables changed during locked swap");
        } else {
            console.log("Vulnerability not Exist: State variables unchanged during locked swap");
        }

        // Original assertions remain for test verification
        assertFalse(token.swapAndLiquifyEnabled());
        assertFalse(token.buyBackEnabled());
    }
}