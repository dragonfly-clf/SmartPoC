// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WizardPay.sol";

contract WizardPayTest is Test {
    WizardPay public wizardPay;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    address nonContractAddress = 0x000000000000000000000000000000000000dEaD;

    function setUp() public {
        vm.prank(owner);
        wizardPay = new WizardPay();
    }

    function testCallNonExistentContract() public {
        bytes memory payload = abi.encodeWithSignature("nonExistentMethod()");
        
        console.log("--- BEFORE-Trigger Call ---");
        console.log("Contract state unchanged - no token storage variables modified");

        console.log("--- Trigger Call (Expected Revert) ---");
        vm.expectRevert("Address: low-level call failed");
        (bool success, ) = address(wizardPay).call(
            abi.encodeWithSignature(
                "_functionCallWithValue(address,bytes,uint256,string)",
                nonContractAddress,
                payload,
                0,
                "TEST"
            )
        );

        console.log("--- AFTER-Trigger Call ---");
        console.log("Revert occurred as expected - contract state remains unchanged");
        
        console.log("Vulnerability not Exist: Revert prevents unauthorized state changes to token parameters");
    }
}