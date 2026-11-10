// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOGEMOON.sol";

contract IDOGEMOON {
    function manage_blacklist(address[] calldata addresses, bool status) external {}
    function transfer(address recipient, uint256 amount) external returns (bool) {}
    function enable_blacklist(bool status) external {}
    function tradingStatus(bool _status, uint256 _deadBlocks) public {}
    function balanceOf(address account) external view returns (uint256) {}
    function isBlacklisted(address account) external view returns (bool) {}
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdead);
    }
}

contract MockRouterStatic {
    function factory() public pure returns (address) {
        return address(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    }
    
    function WETH() public pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract BlacklistTest is Test {
    DOGEMOON token;
    IDOGEMOON itoken;
    address owner = address(0x1);
    address nonOwner = address(0x2);
    address alice = address(0x3);
    address[] addresses;
    
    function setUp() public {
        // Mock PancakeSwap router and factory
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address factoryAddress = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
        
        // Deploy and etch MockRouterStatic at routerAddress
        MockRouterStatic mockRouter = new MockRouterStatic();
        vm.etch(routerAddress, address(mockRouter).code);
        
        // Deploy and etch MockFactory at factoryAddress
        MockFactory mockFactory = new MockFactory();
        vm.etch(factoryAddress, address(mockFactory).code);
        
        // Deploy token and create interface
        vm.startPrank(owner);
        token = new DOGEMOON();
        itoken = IDOGEMOON(address(token));
        token.tradingStatus(true, 0);
        token.enable_blacklist(true);
        vm.stopPrank();
    }

    function testOwnerCanBlacklistAddresses() public {
        addresses.push(alice);

        console.log("--- BEFORE-Trigger: isBlacklisted(alice) ---");
        (bool preSuccess, bytes memory preData) = address(token).call(
            abi.encodeWithSignature("isBlacklisted(address)", alice)
        );
        require(preSuccess, "Pre-query failed");
        bool isBlacklistedBefore = abi.decode(preData, (bool));
        console.log("isBlacklisted before:", isBlacklistedBefore ? "true" : "false");
        console.log("Pre-trigger action: owner will call manage_blacklist([alice], true)");

        console.log("--- Trigger: manage_blacklist([alice], true) ---");
        vm.prank(owner);
        itoken.manage_blacklist(addresses, true);

        console.log("--- AFTER-Trigger: isBlacklisted(alice) ---");
        (bool postSuccess, bytes memory postData) = address(token).call(
            abi.encodeWithSignature("isBlacklisted(address)", alice)
        );
        require(postSuccess, "Post-query failed");
        bool isBlacklistedAfter = abi.decode(postData, (bool));
        console.log("isBlacklisted after:", isBlacklistedAfter ? "true" : "false");
        console.log("Post-trigger action: owner has called manage_blacklist([alice], true)");

        bool stateChanged = (isBlacklistedBefore != isBlacklistedAfter);
        console.log("State changed:", stateChanged ? "YES" : "NO");
        console.log("Exploitation succeeded:", (stateChanged && !isBlacklistedBefore && isBlacklistedAfter) ? "YES" : "NO");

        if (stateChanged && !isBlacklistedBefore && isBlacklistedAfter) {
            console.log("Vulnerability Exists: owner successfully changed isBlacklisted(alice) from false to true via manage_blacklist");
        } else {
            console.log("Vulnerability not Exist: isBlacklisted(alice) did not change from false to true after manage_blacklist");
        }
    }

    function testBlacklistedCannotTransfer() public {
        // Fund Alice with tokens
        uint256 amountToTransfer = 1000;
        vm.prank(owner);
        require(token.transfer(alice, amountToTransfer), "Transfer failed");
        
        // Verify Alice received tokens
        uint256 aliceBalance = token.balanceOf(alice);
        assertEq(aliceBalance, amountToTransfer, "Alice should have tokens");
        
        // Blacklist Alice
        addresses.push(alice);
        vm.prank(owner);
        itoken.manage_blacklist(addresses, true);
        
        // Attempt transfer from Alice (should revert)
        vm.prank(alice);
        vm.expectRevert();
        token.transfer(owner, 100);
    }

    function testNonOwnerCannotBlacklist() public {
        addresses.push(alice);
        
        // Non-owner attempts to blacklist (should revert)
        vm.prank(nonOwner);
        vm.expectRevert();
        itoken.manage_blacklist(addresses, true);
    }
}