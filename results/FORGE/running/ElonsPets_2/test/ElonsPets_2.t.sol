// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ElonsPets.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint256) external {}
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xabc); // Minimal address for pair
    }
}

contract MockUniswapV2Router02 {
    address public factory;
    address public WETH;
    
    // Storage will be set manually
}

contract ElonsPetsOwnerPrivilegeTest is Test {
    ElonsPets token;
    address owner = address(0x1234);
    address nonOwner = address(0x5678);
    address testBot = address(0x9999);

    function setUp() public {
        vm.startPrank(owner);
        
        // Setup mock Uniswap environment
        MockWETH weth = new MockWETH();
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        
        // Create mock router
        MockUniswapV2Router02 routerTemplate = new MockUniswapV2Router02();
        
        // Deploy mock router to Uniswap's mainnet address
        vm.etch(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D),
            address(routerTemplate).code
        );
        
        // Set storage for router
        vm.store(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D),
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(factory))))
        );
        vm.store(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D),
            bytes32(uint256(1)),
            bytes32(uint256(uint160(address(weth))))
        );
        
        // Deploy token contract after setting up router
        token = new ElonsPets();
        
        vm.stopPrank();
    }

    function testOwnerCanSetBots() public {
        address[] memory bots = new address[](1);
        bots[0] = testBot;

        vm.prank(owner);
        token.setBots(bots, true);

        // Transaction should complete successfully without reverting
        assertTrue(true, "Owner should be able to set bots");
    }

    function testNonOwnerCannotSetBots() public {
        address[] memory bots = new address[](1);
        bots[0] = testBot;

        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setBots(bots, true);

        // Final verdict condition
        console.log("Vulnerability not Exist: Access control prevented non-owner bot modification");
    }
}