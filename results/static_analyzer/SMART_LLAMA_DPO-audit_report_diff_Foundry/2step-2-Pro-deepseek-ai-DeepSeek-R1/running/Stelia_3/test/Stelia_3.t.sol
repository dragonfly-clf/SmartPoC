// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Stelia.sol";

contract SteliaTimestampTest is Test {
    Stelia token;
    address owner = address(0x1);
    uint256 constant LOCK_PERIOD = 7 days;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        address mockFactory = address(0xcafebabe1);
        address mockWETH = address(0xcafebabe2);
        address mockPair = address(0xcafebabe3);

        // Mock router factory call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IUniswapV2Router01.factory.selector),
            abi.encode(mockFactory)
        );
        // Mock router WETH call
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IUniswapV2Router01.WETH.selector),
            abi.encode(mockWETH)
        );
        // Mock factory createPair
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(IUniswapV2Factory.createPair.selector),
            abi.encode(mockPair)
        );

        vm.startPrank(owner);
        token = new Stelia();
        vm.stopPrank();
    }

    function testTimestampManipulation() public {
        uint256 lockPeriod = LOCK_PERIOD;
        
        console.log("--- BEFORE-Trigger Lock ---");
        console.log("Current owner (should be original owner): %s", token.owner());

        // Lock contract
        vm.prank(owner);
        token.lock(lockPeriod);
        
        console.log("--- AFTER-Trigger Lock ---");
        console.log("Owner after lock (should be 0): %s", token.owner());
        assertEq(token.owner(), address(0), "Owner should be address(0) after lock");

        // Jump beyond the lock period to simulate timestamp manipulation
        vm.warp(block.timestamp + lockPeriod + 1);

        console.log("--- BEFORE-Trigger Unlock ---");
        console.log("Owner before unlock (should be 0): %s", token.owner());

        // Attempt unlock as previous owner
        vm.prank(owner);
        token.unlock();
        
        console.log("--- AFTER-Trigger Unlock ---");
        address actualOwner = token.owner();
        console.log("Owner after unlock: %s", actualOwner);
        console.log("Expected owner: %s", owner);

        // Vulnerability verification
        if (actualOwner == owner) {
            console.log("Vulnerability not Exist: The unlock function correctly restores ownership after the lock period.");
        } else {
            console.log("Vulnerability Exists: Unlock did not restore ownership.");
        }

        // Maintain original assertion
        assertEq(actualOwner, owner, "Ownership not restored after unlock");
    }

    function testUnlockBeforeLockPeriod() public {
        uint256 lockPeriod = LOCK_PERIOD;
        
        // Lock contract
        vm.prank(owner);
        token.lock(lockPeriod);
        
        // Verify lock state
        assertEq(token.owner(), address(0), "Owner should be address(0)");

        // Attempt premature unlock (should revert)
        vm.prank(owner);
        vm.expectRevert("Contract is locked until 7 days");
        token.unlock();
    }
}