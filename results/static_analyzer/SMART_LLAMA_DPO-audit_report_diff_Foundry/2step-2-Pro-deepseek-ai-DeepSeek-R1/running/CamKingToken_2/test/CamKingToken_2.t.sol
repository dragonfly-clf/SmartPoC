// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CamKingToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdead);
    }
}

contract MockUniswapV2Router {
    address public factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract CamKingTokenTest is Test {
    CamKingToken token;
    address owner = address(0x123);
    uint256 constant LOCK_DURATION = 7 days;
    address constant ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    function setUp() public {
        // Setup mock router environment
        address mockWeth = address(0x456);
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory), mockWeth);
        
        // Simulate the router address having mockRouter's bytecode
        bytes memory mockCode = address(mockRouter).code;
        vm.etch(ROUTER_ADDRESS, mockCode);
        // Set storage slots for factory & WETH in simulated router
        vm.store(ROUTER_ADDRESS, bytes32(0), bytes32(uint256(uint160(address(mockFactory)))));
        vm.store(ROUTER_ADDRESS, bytes32(uint256(1)), bytes32(uint256(uint160(mockWeth))));

        // Deploy token as owner
        vm.prank(owner);
        token = new CamKingToken();
    }

    function testLockUnlockManipulation() public {
        // Lock contract
        vm.prank(owner);
        token.lock(LOCK_DURATION);
        uint256 unlockTime = token.getUnlockTime();

        // Verify locked state
        assertEq(token.owner(), address(0), "Ownership not cleared");

        // Attempt premature unlock (should revert)
        vm.warp(unlockTime - 1);
        
        // Differential check: owner state before unlock attempt
        console.log("--- BEFORE-Trigger Operation ---");
        address prePrematureOwner = token.owner();
        console.log("Current owner state before premature unlock:", prePrematureOwner);

        console.log("--- Trigger Operation (Should Fail) ---");
        vm.prank(owner);
        vm.expectRevert("Contract is locked until 7 days");
        token.unlock();

        console.log("--- AFTER-Trigger Operation ---");
        address postPrematureOwner = token.owner();
        console.log("Current owner state after premature unlock:", postPrematureOwner);
        console.log("Asserting no state change after failed unlock...");
        assertEq(prePrematureOwner, postPrematureOwner, "Ownership changed during failed unlock");
        console.log("-> Premature unlock correctly prevented");

        console.log("\n=================\n");

        // Manipulate time and unlock
        vm.warp(unlockTime + 1);
        
        // Differential check: owner state before legitimate unlock
        console.log("--- BEFORE-Trigger Operation (Legitimate Unlock) ---");
        address preUnlockOwner = token.owner();
        console.log("Current owner state before unlock:", preUnlockOwner);

        console.log("--- Trigger Operation (Unlock) ---");
        vm.prank(owner);
        token.unlock();

        console.log("--- AFTER-Trigger Operation ---");
        address postUnlockOwner = token.owner();
        console.log("Current owner state after unlock:", postUnlockOwner);

        // Verify ownership restored
        assertEq(postUnlockOwner, owner, "Ownership not restored");

        // Final vulnerability verdict - contract behaves correctly
        console.log("Vulnerability not Exist: Lock/unlock mechanism behaves as designed");
    }
}