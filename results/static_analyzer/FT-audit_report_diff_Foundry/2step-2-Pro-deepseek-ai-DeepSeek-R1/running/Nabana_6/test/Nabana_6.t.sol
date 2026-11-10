// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Nabana.sol";

contract MockUniswapV2Router {
    function factory() external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }

    function WETH() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x3333333333333333333333333333333333333333);
    }
}

contract TransferValidationTest is Test {
    Nabana public token;
    address owner = address(this);
    address vestingAddr = address(100);
    address normalUser = address(1);
    address zeroAddr = address(0);
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Deploy mock contracts
        MockUniswapV2Router mockRouter = new MockUniswapV2Router();
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        
        // Mock the hardcoded router address
        vm.etch(HARDCODED_ROUTER, address(mockRouter).code);
        vm.etch(address(0x2222222222222222222222222222222222222222), address(mockFactory).code);
        
        // Deploy Nabana token
        token = new Nabana(vestingAddr);
        
        // Mint tokens to user for testing
        uint256 mintAmount = 1000 * 10 ** token.decimals();
        vm.prank(vestingAddr);
        token.transfer(normalUser, mintAmount);
    }

    function test_transfer_to_zero_address_reverts() public {
        uint256 transferAmount = 100 * 10 ** token.decimals();
        
        vm.prank(normalUser);
        vm.expectRevert("ERC20: transfer to the zero address");
        token.transfer(zeroAddr, transferAmount);
        
        console.log("Vulnerability not Exist: Transfer to zero address correctly reverts");
    }

    function test_transfer_exceeds_balance_reverts() public {
        uint256 balance = token.balanceOf(normalUser);
        
        vm.prank(normalUser);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        token.transfer(address(200), balance + 1);
        
        console.log("Vulnerability not Exist: Exceeds-balance transfer correctly reverts");
    }
}