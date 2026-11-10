// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/arbitrary_location_write_simple.sol";

contract WalletTest is Test {
    Wallet public wallet;

    function setUp() public {
        wallet = new Wallet();
    }

    function test_PushBonusCodeOverflow() public {
        // Variables for storage slots
        bytes32 codeToBonusSlot;
        bytes32 userPointsSlot;
        
        // Set bonus code 123 = 10 at mapping slot 1
        uint256 codeKey = 123;
        uint256 mappingSlotForCode = 1;
        codeToBonusSlot = keccak256(
            abi.encode(codeKey, mappingSlotForCode)
        );
        vm.store(
            address(wallet),
            codeToBonusSlot,
            bytes32(uint256(10))
        );

        // Set current address's points to MAX_UINT256 - 9 at mapping slot 2
        uint256 userAddr = uint256(uint160(address(this)));
        uint256 mappingSlotForUser = 2;
        userPointsSlot = keccak256(
            abi.encode(userAddr, mappingSlotForUser)
        );
        vm.store(
            address(wallet),
            userPointsSlot,
            bytes32(type(uint256).max - 9)
        );

        console2.log("--- BEFORE-Trigger ---");
        uint256 pointsBefore = wallet.userPoints(address(this));
        // Read bonus value directly from storage instead of using getter
        bytes32 loadedBonusValue = vm.load(address(wallet), codeToBonusSlot);
        uint256 bonusValue = uint256(loadedBonusValue);
        console2.log("Points before:", pointsBefore);
        console2.log("Bonus value:", bonusValue);
        uint256 maxUint = type(uint256).max;
        console2.log("Max uint value:", maxUint);
        console2.log("Expected points increment: 10");

        string memory finalVerdict;
        console2.log("--- TRIGGER: Call PushBonusCode(123) ---");
        
        // Track call success status
        bool callSucceeded;
        try wallet.PushBonusCode(123) {
            callSucceeded = true;
        } catch {
            callSucceeded = false;
        }

        if (callSucceeded) {
            console2.log("Call did not revert");
            uint256 pointsAfter = wallet.userPoints(address(this));
            console2.log("--- AFTER-Trigger ---");
            console2.log("Points after:", pointsAfter);

            // Calculate expected overflow value with unchecked math
            unchecked {
                uint256 expectedOverflowResult = pointsBefore + bonusValue;
                if (pointsAfter == expectedOverflowResult) {
                    console2.log("Points after match expected overflow value:", expectedOverflowResult);
                    finalVerdict = "Vulnerability Exists: Storage change confirmed";
                } else {
                    console2.log("Points after do not match expected overflow value");
                    console2.log("Expected:", expectedOverflowResult, " Actual:", pointsAfter);
                    finalVerdict = "Vulnerability not Exist: Unexpected state change";
                }
            }
        } else {
            console2.log("Call reverted safely");
            uint256 pointsAfter = wallet.userPoints(address(this));
            console2.log("--- AFTER-Trigger ---");
            console2.log("Points after:", pointsAfter);
            
            if (pointsAfter == pointsBefore) {
                console2.log("Points unchanged after revert");
                finalVerdict = "Vulnerability not Exist: Reverted safely as expected";
            } else {
                console2.log("Points changed unexpectedly after revert");
                finalVerdict = "Vulnerability not Exist: State changed despite revert";
            }
        }
        
        // Final verdict output
        console2.log(finalVerdict);
    }
}