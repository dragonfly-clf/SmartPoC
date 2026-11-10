// SPDX-License-Identifier: MIT
pragma solidity 0.7.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BNRG.sol";

contract BNRG_EventTest is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    BNRG token;
    address owner = address(0x1);
    address staking = address(0x2);
    address alice = address(0x3);
    address bob = address(0x4);
    
    function setUp() public {
        vm.startPrank(owner);
        token = new BNRG();
        token.setStakingContract(staking);
        token.setBotProtection(false); // Disable transfer restrictions
        vm.stopPrank();
    }

    function test_mint_emits_Transfer_event() public {
        uint256 mintAmount = 1000;
        
        console.log("--- BEFORE-Trigger ---");
        console.log("Testing mint() function event emission");
        
        console.log("--- Trigger mint ---");
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner, mintAmount);
        
        vm.prank(owner);
        token.mint(mintAmount);
        
        console.log("--- AFTER-Trigger ---");
        console.log("Event verification completed");
        console.log("Vulnerability not Exist: Transfer event successfully emitted during mint");
    }

    function test_deliver_emits_Transfer_event() public {
        uint256 deliverAmount = 500;
        
        console.log("--- BEFORE-Trigger ---");
        console.log("Testing deliver() function event emission");
        
        console.log("--- Trigger deliver ---");
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), alice, deliverAmount);
        
        vm.prank(staking);
        token.deliver(alice, deliverAmount);
        
        console.log("--- AFTER-Trigger ---");
        console.log("Event verification completed");
        console.log("Vulnerability not Exist: Transfer event successfully emitted during deliver");
    }

    function test_transferFrom_emits_Transfer_event_toZeroAddress() public {
        uint256 amount = 1000;
        
        console.log("--- BEFORE-Trigger (setup) ---");
        // Mint tokens directly to Alice
        vm.prank(owner);
        token.mint(amount);
        vm.prank(owner);
        token.transfer(alice, amount);
        
        // Alice approves Bob for token transfer
        vm.prank(alice);
        token.approve(bob, amount);
        
        console.log("--- Trigger transferFrom ---");
        // Check for Transfer event
        vm.expectEmit(true, true, true, true);
        emit Transfer(alice, address(0), amount);
        
        // Execute transfer to zero address
        vm.prank(bob);
        token.transferFrom(alice, address(0), amount);
        
        console.log("--- AFTER-Trigger ---");
        console.log("Event verification completed");
        console.log("Vulnerability not Exist: Transfer event successfully emitted during transferFrom to zero address");
    }
}