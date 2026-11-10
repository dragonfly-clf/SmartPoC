// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PieShare.sol";

contract PieShareBlacklistTest is Test {
    PieShare token;
    address owner = address(0x1);
    address alice = address(0x2);
    address bob = address(0x3);

    function setUp() public {
        address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        
        // Mock router and factory interactions
        address mockFactory = address(0x123);
        address mockWETH = address(0x456);
        address mockPair = address(0x789);
        
        // Mock PancakeRouter calls
        vm.mockCall(
            router,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            router,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory pair creation
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        vm.startPrank(owner);
        token = new PieShare();
        token.excludeFromFees(alice, true);
        token.excludeFromFees(bob, true);
        token.transfer(alice, 100 ether);
        vm.stopPrank();
    }

    function testBlacklistBlocksTransfers() public {
        // Test pre-blacklist transfer
        vm.prank(alice);
        token.transfer(bob, 10 ether);
        assertEq(token.balanceOf(bob), 10 ether, "Initial transfer failed");

        // Differential validation: check blacklist status pre-change
        console.log("--- BEFORE-Trigger Status ---");
        bool beforeStatus = token._isBlacklisted(alice);
        console.log("Alice blacklisted status (BEFORE):", beforeStatus ? "BLACKLISTED" : "NOT BLACKLISTED");
        
        // Execute the state-changing operation
        console.log("--- Trigger blacklistAddress ---");
        vm.prank(owner);
        token.blacklistAddress(alice, true);

        // Differential validation: check status post-change
        console.log("--- AFTER-Trigger Status ---");
        bool afterStatus = token._isBlacklisted(alice);
        console.log("Alice blacklisted status (AFTER):", afterStatus ? "BLACKLISTED" : "NOT BLACKLISTED");

        // Vulnerability existence check
        if (afterStatus && !beforeStatus) {
            console.log("Vulnerability Exists: Blacklist state successfully modified");
        } else {
            console.log("Vulnerability not Exist: Blacklist state unchanged");
        }

        // Verify transfer blocking functionality
        vm.prank(alice);
        vm.expectRevert(bytes("Blacklisted address"));
        token.transfer(bob, 10 ether);
        assertEq(token.balanceOf(bob), 10 ether);
    }
}