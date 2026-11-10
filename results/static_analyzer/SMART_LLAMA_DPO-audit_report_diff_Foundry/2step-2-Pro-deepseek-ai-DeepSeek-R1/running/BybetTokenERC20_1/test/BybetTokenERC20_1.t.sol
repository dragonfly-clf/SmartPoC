// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BybetTokenERC20.sol";

contract BybetTokenERC20Test is Test {
    BybetTokenERC20 token;
    address owner = address(0x1);
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant factoryAddress = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
    address constant WETHAddress = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant BUSD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    function setUp() public {
        vm.label(owner, "Owner");
        vm.startPrank(owner);
        
        // Deploy mock implementations
        MockRouter routerMock = new MockRouter();
        MockFactory factoryMock = new MockFactory();
        BUSDMock busdMock = new BUSDMock();
        
        // Mock router functions
        vm.etch(routerAddress, address(routerMock).code);
        // Mock factory functions
        vm.etch(factoryAddress, address(factoryMock).code);
        // Mock BUSD token
        vm.etch(BUSD_ADDRESS, address(busdMock).code);
        
        // Deploy token using mocked dependencies
        token = new BybetTokenERC20();

        // Configure launch time to set proper fees
        token.configLaunchTime(block.timestamp);
        
        // Seed token contract with BUSD to avoid distribution issues
        uint256 busdAmount = 10 ether;
        deal(BUSD_ADDRESS, address(token), busdAmount);

        vm.stopPrank();
    }

    function test_SwapFailureLeavesAllowanceSet() public {
        vm.startPrank(owner);

        // Transfer tokens to contract to simulate accumulated fees
        uint256 amount = 1_000_000 * 10 ** 18;
        token.transfer(address(token), amount);
        
        // Print pre-trigger state snapshot
        console.log("--- BEFORE-Trigger State ---");
        uint256 preBalance = token.balanceOf(address(token));
        uint256 preAllowance = token.allowance(address(token), routerAddress);
        
        console.log("Contract Token Balance (Before):", preBalance);
        console.log("Router Allowance (Before):", preAllowance);
        
        // Print trigger action
        console.log("--- TRIGGER ACTION ---");
        console.log("Calling token.manualDistributeBuyFee()");
        token.manualDistributeBuyFee();
        
        // Print post-trigger state snapshot
        console.log("--- AFTER-Trigger State ---");
        uint256 postBalance = token.balanceOf(address(token));
        uint256 postAllowance = token.allowance(address(token), routerAddress);
        
        console.log("Contract Token Balance (After):", postBalance);
        console.log("Router Allowance (After):", postAllowance);
        
        // Differential verification and verdict
        console.log("--- VERDICT ---");
        bool balanceUnchanged = (postBalance == preBalance);
        bool allowanceSet = (postAllowance != preAllowance);
        bool vulnerabilityExists = balanceUnchanged && allowanceSet;
        
        console.log("Token Contract Balance Changed?: %s", balanceUnchanged ? "No" : "Yes");
        console.log("Router Allowance Changed?: %s", allowanceSet ? "Yes" : "No");
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log(
                "Allowance set without balance reduction:",
                postAllowance - preAllowance,
                "tokens approved but not spent"
            );
            console.log("Vulnerability Exists: Failed swap leaves allowance set without balance reduction");
        } else {
            console.log("Vulnerability not Exist: Either balance changed (swap success) or allowance not set");
        }
        
        vm.stopPrank();
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73);
    }
    
    function WETH() external pure returns (address) {
        return address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external pure {  // Marked as pure to resolve mutability warning
        // Silent failure - no revert, no state changes
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract BUSDMock {
    mapping(address => uint256) public balanceOf;
    
    function transfer(address, uint256) external pure returns (bool) {
        return true;
    }
}