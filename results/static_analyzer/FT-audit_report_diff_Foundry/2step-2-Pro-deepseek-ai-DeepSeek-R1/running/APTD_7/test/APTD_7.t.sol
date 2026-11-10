// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/APTD.sol";

contract APTDFeeReceiverTest is Test {
    APTD aptd;
    address deployer = 0x22ba8aAb4c60Ac95e61CFC41dF8d2675aeb87C0b;
    address attacker = makeAddr("attacker");
    address newFeeReceiver = makeAddr("newFeeReceiver");
    
    // Mock addresses for DEX components
    address constant MOCK_WBNB = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    address constant MOCK_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address MOCK_FACTORY = address(0x123);
    address MOCK_PAIR = address(0x456);

    function setUp() public {
        vm.startPrank(deployer);
        
        // Mock router factory() call
        vm.mockCall(
            MOCK_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        
        // Mock createPair() call for ANY token pair
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );
        
        // Deploy contract (will use mocked addresses)
        aptd = new APTD();
        vm.stopPrank();
    }

    function testFeeReceiverChangeByNonOwner() public {
        console.log("--- BEFORE-Trigger ---");
        address originalFeeReceiver = aptd.devFeeReceiver();
        console.log("Original Fee Receiver:", originalFeeReceiver);

        console.log("--- Trigger: Attacker calls setFeeReceivers ---");
        vm.prank(attacker);
        try aptd.setFeeReceivers(newFeeReceiver) {
            console.log("Attacker call: did not revert");
        } catch {
            console.log("Attacker call: reverted (expected behavior)");
        }

        console.log("--- AFTER-Trigger ---");
        address currentFeeReceiver = aptd.devFeeReceiver();
        console.log("Current Fee Receiver:", currentFeeReceiver);

        if (originalFeeReceiver != currentFeeReceiver) {
            console.log("Verdict: Vulnerability exists because fee receiver changed");
            console.log("Vulnerability Exists: non-owner can change fee receiver");
        } else {
            console.log("Verdict: Vulnerability not exist due to unchanged state");
            console.log("Vulnerability not Exist: access control prevents forbidden changes");
        }
    }
}