// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SPONGS.sol";

contract SPONGSTest is Test {
    SPONGS token;
    address owner = address(this);
    address userA = address(0x1);
    address tokenA = makeAddr("tokenA");
    address tokenB = makeAddr("tokenB");
    address ammA = makeAddr("ammA");
    
    // Predefined mock addresses
    address mockFactory = makeAddr("mockFactory");
    address mockPair = makeAddr("mockPair");
    address mockRouter = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function setUp() public {
        // Mock router calls
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(mockFactory))
        );
        
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(1))
        );
        
        // Mock factory createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Initialize token contract
        token = new SPONGS();
        
        // Set code for tokens to be recognized as contracts
        vm.etch(tokenA, new bytes(1));
        vm.etch(tokenB, new bytes(1));
        vm.etch(ammA, new bytes(1));
        
        // Whitelist custom AMM
        token.setWhiteListAMM(ammA, true);
    }

    function testRewardTokenCountConsistency() public {
        console.log("--- BEFORE-First setRewardTokenWithCustomAMM ---");
        uint256 initialCount = token.getRewardTokenSelectionCount(tokenA);
        console.log("Initial count for tokenA:", initialCount);

        console.log("--- Trigger First setRewardTokenWithCustomAMM ---");
        vm.prank(userA);
        token.setRewardTokenWithCustomAMM(tokenA, ammA);
        
        console.log("--- AFTER-First setRewardTokenWithCustomAMM ---");
        uint256 afterFirstCount = token.getRewardTokenSelectionCount(tokenA);
        console.log("Count after first call:", afterFirstCount);

        console.log("--- BEFORE-Second setRewardTokenWithCustomAMM ---");
        uint256 beforeSecondCount = token.getRewardTokenSelectionCount(tokenA);
        console.log("Count before second call:", beforeSecondCount);

        console.log("--- Trigger Second setRewardTokenWithCustomAMM ---");
        vm.prank(userA);
        token.setRewardTokenWithCustomAMM(tokenA, ammA);
        
        console.log("--- AFTER-Second setRewardTokenWithCustomAMM ---");
        uint256 afterSecondCount = token.getRewardTokenSelectionCount(tokenA);
        console.log("Count after second call:", afterSecondCount);

        // Differential verification
        uint256 change = afterSecondCount - beforeSecondCount;
        if (change > 0) {
            console.log("Vulnerability Exists: Token selection count increased by %d", change);
        } else {
            console.log("Vulnerability not Exist: Token selection count remained constant");
        }
    }
}