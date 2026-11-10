// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BetSwampERC20Token.sol";

contract MockRouter {
    function factory() external view returns (address) {
        return address(this);
    }
    
    function WETH() external view returns (address) {
        return address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
    
    function createPair(address, address) external pure returns (address) {
        return address(0x123456);
    }
}

contract MaliciousToken {
    mapping(address => uint256) public balanceOf;
    
    function mint(address account, uint256 amount) public {
        balanceOf[account] = amount;
    }
    
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract ClearStuckTokenTest is Test {
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant OWNER_ADDRESS = address(0x1);
    BetSwampERC20Token token;
    MaliciousToken maliciousToken;

    function setUp() public {
        // Setup MockRouter at expected address
        bytes memory routerRuntimeCode = type(MockRouter).runtimeCode;
        vm.etch(ROUTER_ADDRESS, routerRuntimeCode);

        // Deploy contracts as owner
        vm.startPrank(OWNER_ADDRESS);
        token = new BetSwampERC20Token();
        maliciousToken = new MaliciousToken();
        maliciousToken.mint(address(token), 1000e18);
        vm.stopPrank();
    }

    function testClearStuckTokenIgnoresTransferFailure() public {
        console.log("--- BEFORE-Trigger ClearStuckToken ---");
        uint256 preBalance = maliciousToken.balanceOf(address(token));
        console.log("Token contract balance of maliciousToken:", preBalance);

        console.log("--- Trigger clearStuckTokenBalance ---");
        // Attempt to clear stuck tokens - should fail silently
        vm.prank(OWNER_ADDRESS);
        token.clearStuckTokenBalance(OWNER_ADDRESS, address(maliciousToken));

        console.log("--- AFTER-Trigger ClearStuckToken ---");
        uint256 postBalance = maliciousToken.balanceOf(address(token));
        console.log("Token contract balance of maliciousToken:", postBalance);

        // Compare balances to verify state persistence
        if (preBalance == postBalance) {
            console.log("Vulnerability Exists: Token balance unchanged after failed transfer, function ignored failure");
        } else {
            console.log("Vulnerability not Exist: Token balance changed, transfer succeeded unexpectedly");
        }

        // Original assertion for test validity
        assertEq(preBalance, postBalance, "Balance should remain after failed transfer");
    }
}