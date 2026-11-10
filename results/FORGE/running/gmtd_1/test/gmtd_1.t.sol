// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GMTdoge.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint256) external {}
}

contract MockPair {
    function balanceOf(address) external pure returns (uint256) { return 0; }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract Audit_BlacklistTest is Test {
    GMTdoge token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);
    address presaler = 0xe269e0D54B95F3EBA76483dfB3ce3bE28B427eDA;

    function setUp() public {
        // Deploy mock contracts
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));

        // Mock the PancakeSwap router address
        address routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(routerAddr, address(mockRouter).code);

        // Deploy token contract
        vm.prank(owner);
        token = new GMTdoge();
        
        vm.warp(block.timestamp + 1 days); // Enable transfers
    }

    function test_blacklisted_address_cannot_transfer() public {
        // Presale address transfers tokens to Alice
        uint256 amount = 1000 * 10 ** token.decimals();
        vm.prank(presaler);
        token.transfer(alice, amount);

        // Verify Alice has tokens
        assertEq(token.balanceOf(alice), amount);

        // Store initial state data
        console.log("--- BEFORE-Trigger Blacklist ---");
        bool initialBlacklistStatus = token.isBlacklisted(alice);
        console.log("Alice initial blacklist status:", initialBlacklistStatus);
        
        // Trigger vulnerability: Owner blacklists Alice
        console.log("--- Trigger Blacklist ---");
        address[] memory addresses = new address[](1);
        addresses[0] = alice;
        vm.prank(owner);
        token.manage_blacklist(addresses, true);

        // Verify state change after vulnerability trigger
        console.log("--- AFTER-Trigger Blacklist ---");
        bool finalBlacklistStatus = token.isBlacklisted(alice);
        console.log("Alice final blacklist status:", finalBlacklistStatus);
        
        // Determine vulnerability verdict (state change verification)
        bool stateChanged = (initialBlacklistStatus != finalBlacklistStatus);
        console.log("Blacklist state changed:", stateChanged ? "YES" : "NO");

        // Alice attempts to transfer tokens - should revert with "Blacklisted"
        vm.prank(alice);
        vm.expectRevert("Blacklisted");
        token.transfer(bob, amount / 10);

        // Verify token balances remain unchanged
        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(bob), 0);

        // Final vulnerability verdict
        if (stateChanged) {
            console.log("Vulnerability Exists: Blacklist state successfully modified");
        } else {
            console.log("Vulnerability not Exist: Blacklist state remains unchanged");
        }
    }

    function test_owner_can_mass_blacklist() public {
        // Create multiple addresses to blacklist
        address[] memory addresses = new address[](3);
        addresses[0] = address(0xA);
        addresses[1] = address(0xB);
        addresses[2] = address(0xC);

        console.log("--- BEFORE-Trigger Mass Blacklist ---");
        bool[3] memory initialStates;
        for (uint i=0; i<addresses.length; i++) {
            initialStates[i] = token.isBlacklisted(addresses[i]);
            console.log("Address", addresses[i], "initial blacklist:", initialStates[i]);
        }
        
        // Trigger: Owner blacklists multiple addresses
        console.log("--- Trigger Mass Blacklist ---");
        vm.prank(owner);
        token.manage_blacklist(addresses, true);

        console.log("--- AFTER-Trigger Mass Blacklist ---");
        bool allStatesChanged = true;
        for (uint i=0; i<addresses.length; i++) {
            bool currentStatus = token.isBlacklisted(addresses[i]);
            console.log("Address", addresses[i], "final blacklist:", currentStatus);
            
            // Check state transition pattern (false->true expected)
            if (!initialStates[i] && currentStatus) {
                console.log("  + State changed correctly (false->true)");
            } else {
                console.log("  ! Unexpected state transition");
                allStatesChanged = false;
            }
        }
        
        // Verify all addresses are blacklisted
        assertTrue(token.isBlacklisted(address(0xA)));
        assertTrue(token.isBlacklisted(address(0xB)));
        assertTrue(token.isBlacklisted(address(0xC)));
        
        // Final vulnerability verdict
        if (allStatesChanged) {
            console.log("Vulnerability Exists: All addresses blacklist state modified successfully");
        } else {
            console.log("Vulnerability not Exist: Mass blacklist state changes incomplete");
        }
    }
}