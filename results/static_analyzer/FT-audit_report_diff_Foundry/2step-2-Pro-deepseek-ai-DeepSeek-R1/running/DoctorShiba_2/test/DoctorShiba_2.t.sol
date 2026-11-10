// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DoctorShiba.sol";

contract DoctorShibaAddressTest is Test {
    DoctorShiba token;
    address owner;
    address nonContract = address(0x123);

    function setUp() public {
        token = new DoctorShiba();
        owner = token.owner();
    }

    // Test to verify Address library functionality with non-contract
    function testFunctionCallMisleadingErrorMessage() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Non-contract address:", nonContract);
        console.log("Calling isContract function");

        console.log("--- Trigger Call ---");
        vm.prank(owner);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature(
                "isContract(address)", 
                nonContract
            )
        );

        console.log("--- AFTER-Trigger ---");
        if (!success) {
            console.log("Call failed as expected");
            console.log("Vulnerability Exists: Function call reverted with misleading error on non-contract address");
        } else {
            console.log("Call succeeded unexpectedly");
            console.log("Vulnerability not Exist: Function call executed successfully on non-contract address");
        }
    }
}