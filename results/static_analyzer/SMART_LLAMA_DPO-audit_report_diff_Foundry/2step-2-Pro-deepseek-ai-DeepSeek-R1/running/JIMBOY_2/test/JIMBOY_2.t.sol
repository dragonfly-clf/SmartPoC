// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/JIMBOY.sol";

contract JIMBOYTest is Test {
    JIMBOY token;
    address owner = address(0x1);
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        vm.startPrank(owner);
        token = new JIMBOY();
        vm.deal(owner, 100 ether);
        vm.stopPrank();
    }

    function testDuplicatePairCreation() public {
        vm.startPrank(owner);

        // Create mock contracts
        MockFactory mockFactory = new MockFactory();

        // Mock Pancake Router calls
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(address(mockFactory))
        );
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(address(0xdead))
        );

        // Initial state before first setTrading
        console.log("--- BEFORE-FIRST Trigger: Verify initial state ---");
        address initialPair = token.uniswapV2Pair();
        console.log("Initial pair address:", address(initialPair));
        require(initialPair == address(0), "Initial pair should be zero");
        
        console.log("--- Trigger FIRST setTrading(true) ---");
        token.setTrading(true);
        
        console.log("--- AFTER-FIRST Trigger: Check pair creation ---");
        address pair1 = token.uniswapV2Pair();
        console.log("First pair created at:", address(pair1));
        require(pair1 != address(0), "First pair creation failed");
        
        console.log("--- BEFORE-SECOND Trigger: Pairs state ---");
        address preSecondPair = token.uniswapV2Pair();
        console.log("Current active pair (before second trigger):", address(preSecondPair));
        
        console.log("--- Trigger SECOND setTrading(true) ---");
        token.setTrading(true);
        
        console.log("--- AFTER-SECOND Trigger: Check new pair creation ---");
        address pair2 = token.uniswapV2Pair();
        console.log("Second pair created at:", address(pair2));
        require(pair2 != address(0), "Second pair creation failed");
        
        console.log("--- Differential Analysis ---");
        console.log("First pair address: ", address(pair1));
        console.log("Second pair address:", address(pair2));
        
        bool duplicatePairsCreated = (pair1 != pair2);
        if (duplicatePairsCreated) {
            console.log("Vulnerability Exists: Duplicate pair creation detected - protocol now uses multiple pair contracts");
        } else {
            console.log("Vulnerability not Exist: Pairs are identical - setTrading maintains consistent pair");
        }
        
        // Also maintain original test assertion
        assertTrue(pair1 != pair2, "Duplicate pair creation detected");

        vm.stopPrank();
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new EmptyContract());
    }
}

contract EmptyContract {}