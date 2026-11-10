// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FortuneCookieV2.sol";

contract AuditIssueTest is Test {
    FortuneCookieV2 token;
    address owner = address(0x1);
    address router = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockPair = address(0xdead);
    address mockWETH = address(0xc0ffee);

    function setUp() public {
        // Mock Uniswap router calls
        vm.etch(router, new bytes(0x42)); // Create dummy bytecode at router address
        vm.mockCall(
            router,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(this)) // Return address(this) for factory calls
        );
        vm.mockCall(
            router,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair
        vm.mockCall(
            address(this),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token
        vm.startPrank(owner);
        token = new FortuneCookieV2();
        vm.stopPrank();
    }

    function testDuplicateAirdrop() public {
        address recipient = address(0x123);
        address[] memory recipients = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        
        // Set duplicate recipient in same transaction
        recipients[0] = recipient;
        recipients[1] = recipient;
        amounts[0] = 100 ether;
        amounts[1] = 100 ether;

        // --- BEFORE-Trigger Airdrop ---
        console.log("--- BEFORE-Trigger Airdrop ---");
        uint256 preBalance = token.balanceOf(recipient);
        console.log("Recipient balance before:", preBalance);

        // --- Trigger Airdrop ---
        console.log("--- Trigger Airdrop ---");
        vm.prank(owner);
        token.airDrop(recipients, amounts); // Critical action

        // --- AFTER-Trigger Airdrop ---
        console.log("--- AFTER-Trigger Airdrop ---");
        uint256 postBalance = token.balanceOf(recipient);
        console.log("Recipient balance after:", postBalance);
        uint256 balanceDiff = postBalance - preBalance;
        console.log("Airdropped amount:", balanceDiff);

        // --- Comparison Verdict ---
        console.log("--- Comparison Verdict ---");
        console.log("Balance change: %s tokens", balanceDiff);
        if (balanceDiff == 200 ether) {
            console.log("Exploitation success: true (OVER-credited duplicate)");
            console.log("Vulnerability Exists: Duplicate recipient illegally got 200 tokens");
        } else if (balanceDiff == 100 ether) {
            console.log("Exploitation success: false (Properly handled)");
            console.log("Vulnerability not Exist: Correctly handled duplicate recipient");
        } else {
            console.log("Unexpected balance change!");
            console.log("Vulnerability not Exist: Contract logic inconsistent");
        }

        // Final verdict log (REQUIREMENT: exactly one final line)
        if (balanceDiff == 200 ether) {
            console.log("Vulnerability Exists: Duplicate recipient over-credited by contract");
        } else if (balanceDiff == 100 ether) {
            console.log("Vulnerability not Exist: Contract correctly processed duplicate");
        } else {
            console.log("Vulnerability not Exist: Unexpected behavior beyond duplicate issue");
        }
    }
}