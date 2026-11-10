// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SpaceGrok.sol";
import {console2} from "forge-std/console2.sol"; // Added for explicit logging

contract MockRecoverTokensToken {
    mapping(address => uint256) private _balances;

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address, uint256) external returns (bool) {
        // Always return false to simulate transfer failure
        return false;
    }
    
    // Helper to set balances for testing
    function mint(address account, uint256 amount) external {
        _balances[account] = amount;
    }
}

contract MockUniswapV2Router {
    address public factory;
    
    function setFactory(address _factory) public {
        factory = _factory;
    }
    
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract SpaceGrokTest is Test {
    SpaceGrok spaceGrok;
    MockRecoverTokensToken token;
    address owner = makeAddr("owner");
    address user1 = makeAddr("user1");
    uint256 tokensToRecover = 100 ether;

    function setUp() public {
        // Create mock Uniswap environment
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouterImpl = new MockUniswapV2Router();
        mockRouterImpl.setFactory(address(mockFactory));
        
        address routerAddr = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        // Simulate router deployment by injecting code
        vm.etch(routerAddr, address(mockRouterImpl).code);
        
        // Set factory storage slot
        vm.store(
            routerAddr,
            bytes32(0),
            bytes32(uint256(uint160(address(mockFactory))))
        );

        // Deploy SpaceGrok
        vm.startPrank(owner);
        spaceGrok = new SpaceGrok();
        
        // Deploy the token we want to test recovery for
        token = new MockRecoverTokensToken();
        vm.stopPrank();
    }

    function testUncheckedTokenTransfer() public {
        // Setup tokens for recovery
        token.mint(address(spaceGrok), tokensToRecover);

        // Capture initial state SLOT1
        uint256 spaceGrokBalanceBefore = token.balanceOf(address(spaceGrok));
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        console2.log("--- BEFORE recoverTokens ---");
        console2.log("SpaceGrok token balance:", spaceGrokBalanceBefore);
        console2.log("Owner token balance:", ownerBalanceBefore);
        
        // Verify initial balances with assertions
        assertEq(spaceGrokBalanceBefore, tokensToRecover, "Initial token balance incorrect");
        assertEq(ownerBalanceBefore, 0, "Owner should start with 0 tokens");

        console2.log("--- TRIGGER recoverTokens CALL ---");
        // Attempt to recover tokens - should not revert even though transfer fails
        vm.prank(owner);
        spaceGrok.recoverTokens(address(token), tokensToRecover);

        console2.log("--- AFTER recoverTokens ---");
        // Capture post-execution state SLOT1
        uint256 spaceGrokBalanceAfter = token.balanceOf(address(spaceGrok));
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        console2.log("SpaceGrok token balance:", spaceGrokBalanceAfter);
        console2.log("Owner token balance:", ownerBalanceAfter);

        // Verify transfer didn't occur with assertions
        assertEq(spaceGrokBalanceAfter, tokensToRecover, "Token balance should remain unchanged");
        assertEq(ownerBalanceAfter, 0, "Owner should not receive tokens");

        // Differential evaluation
        bool stateUnchanged = 
            (spaceGrokBalanceAfter == spaceGrokBalanceBefore) && 
            (ownerBalanceAfter == ownerBalanceBefore);
        
        // Final vulnerability determination
        if (stateUnchanged) {
            console2.log("Vulnerability Exists: Token balances unchanged shows recoverTokens ignores transfer failures");
        } else {
            console2.log("Vulnerability not Exist: Transfer behavior matched expectations");
        }
    }
}