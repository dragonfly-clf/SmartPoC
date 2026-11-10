// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GARFIELD.sol";

contract MockWETH {
    // Minimal WETH implementation
}

contract MockERC20 {
    function transfer(address, uint256) public returns (bool) {
        return true;
    }
}

contract MockFactory {
    function createPair(address, address) public returns (address) {
        return address(new MockERC20());
    }
}

contract MockRouter {
    MockFactory public factory;
    address public WETH;

    constructor() public {
        factory = new MockFactory();
        WETH = address(new MockWETH());
    }
}

contract ActivateContractTest is Test {
    GARFIELD token;
    address owner = address(0x1);
    MockRouter router;
    
    function setUp() public {
        router = new MockRouter();
        vm.prank(owner);
        token = new GARFIELD(payable(address(router)));
    }

    function test_activateContract_can_be_called_multiple_times() public {
        vm.startPrank(owner);
        
        console.log("--- BEFORE-Trigger ---");
        uint256 initialRewardCycleBlock = token.getRewardCycleBlock();
        console.log("Initial rewardCycleBlock:", initialRewardCycleBlock);

        console.log("--- Trigger First Activation ---");
        token.activateContract();
        console.log("First activation completed");

        console.log("--- Trigger Second Activation ---");
        bool secondCallSuccess = true;
        try token.activateContract() {
            // Call succeeded
        } catch {
            secondCallSuccess = false;
        }
        console.log("Second activation completed without revert:", secondCallSuccess);

        console.log("--- AFTER-Trigger ---");
        uint256 finalRewardCycleBlock = token.getRewardCycleBlock();
        console.log("Final rewardCycleBlock:", finalRewardCycleBlock);
        
        if (secondCallSuccess) {
            console.log("Vulnerability Exists: activateContract lacks call restrictions and can be called multiple times without reverting");
        } else {
            console.log("Vulnerability not Exist: Second activation call reverted");
        }
        
        vm.stopPrank();
    }
}