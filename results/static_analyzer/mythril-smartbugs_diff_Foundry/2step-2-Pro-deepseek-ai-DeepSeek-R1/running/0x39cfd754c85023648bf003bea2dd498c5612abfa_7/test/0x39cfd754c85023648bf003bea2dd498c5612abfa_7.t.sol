// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract TokenBankUnderflowTest is Test {
    TokenBank public tokenBank;
    address public constant EXTREME_ADDRESS = address(type(uint160).max);
    address public newOwnerAddress = address(0xCAFE);

    function setUp() public {
        tokenBank = new TokenBank();
    }

    function test_ChangeOwnerUnderflow() public {
        // Track success status of all steps
        bool successStep2;
        bool successStep3;
        bool successStep4;
        bool successStep5;
        
        console.log("--- BEFORE-Trigger Ownership Change ---");
        console.log("No state variables requirable for this vulnerability");

        console.log("--- Trigger Step 2: changeOwner(EXTREME_ADDRESS) ---");
        (successStep2, ) = address(tokenBank).call(
            abi.encodeWithSelector(tokenBank.changeOwner.selector, EXTREME_ADDRESS)
        );
        console.log("Step 2: changeOwner", successStep2 ? "succeeded" : "failed");

        console.log("--- Trigger Step 3: confirmOwner(from EXTREME_ADDRESS) ---");
        vm.prank(EXTREME_ADDRESS);
        (successStep3, ) = address(tokenBank).call(
            abi.encodeWithSelector(tokenBank.confirmOwner.selector)
        );
        console.log("Step 3: confirmOwner", successStep3 ? "succeeded" : "failed");

        console.log("--- Trigger Step 4: changeOwner(newOwnerAddress) ---");
        vm.prank(EXTREME_ADDRESS);
        (successStep4, ) = address(tokenBank).call(
            abi.encodeWithSelector(tokenBank.changeOwner.selector, newOwnerAddress)
        );
        console.log("Step 4: changeOwner", successStep4 ? "succeeded" : "failed");

        console.log("--- Trigger Step 5: confirmOwner(from newOwnerAddress) ---");
        vm.prank(newOwnerAddress);
        (successStep5, ) = address(tokenBank).call(
            abi.encodeWithSelector(tokenBank.confirmOwner.selector)
        );
        console.log("Step 5: confirmOwner", successStep5 ? "succeeded" : "failed");

        console.log("--- AFTER-Trigger Ownership Change ---");
        if (successStep2 && successStep3 && successStep4 && successStep5) {
            console.log("Vulnerability Exists: successfully completed ownership change sequence without required underflow");
        } else {
            console.log("Vulnerability not Exist: one or more steps failed during ownership change sequence");
        }
    }
}