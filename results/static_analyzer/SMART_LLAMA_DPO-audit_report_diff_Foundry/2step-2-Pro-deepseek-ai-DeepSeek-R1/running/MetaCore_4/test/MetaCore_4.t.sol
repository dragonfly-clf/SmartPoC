// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaCore.sol";

contract MetaCorePrivilegeTest is Test {
    MetaCore public token;
    address owner = address(0x1);
    address attacker = address(0x666);
    address newAddress = address(0x999);
    address marketingWallet = address(0x100);
    
    // Mock components for proper initialization
    MockUniswapFactory public factory;
    MockUniswapRouter public router;
    address weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        // Deploy necessary mock contracts
        factory = new MockUniswapFactory();
        router = new MockUniswapRouter(address(factory), weth);

        // Deploy token with owner privileges
        vm.prank(owner);
        token = new MetaCore(marketingWallet, 1, address(router));
    }

    // Test 1: Verify owner can call setUniswapUSDAddress
    function test_owner_can_set_uniswap_address() public {
        vm.prank(owner);
        token.setUniswapUSDAddress(newAddress);
        // Success if no revert
    }

    // Test 2: Verify non-owners cannot call setUniswapUSDAddress
    function test_non_owner_cannot_set_uniswap_address() public {
        vm.startPrank(attacker);
        (bool success, ) = address(token).call(abi.encodeWithSelector(token.setUniswapUSDAddress.selector, newAddress));
        vm.stopPrank();

        // Vulnerability verification
        if (success) {
            console.log("Vulnerability Exist: Non-owner can set uniswap address");
        } else {
            console.log("Vulnerability not Exist: Non-owner access properly restricted");
        }
        
        // Security assert
        assertFalse(success, "Access control failure");
    }
}

// Minimal implementations to satisfy MetaCore dependencies
contract MockUniswapFactory {
    function createPair(address, address) external returns (address) {
        return address(0x123); // Dummy pair address
    }
}

contract MockUniswapRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}