// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Guitarist.sol";

contract FunctionCallTest is Test {
    Guitarist guitarist;
    address owner = address(1);
    address nonContract = address(0x1234);
    bytes mockData = "arbitrary_data";

    function setUp() public {
        vm.startPrank(owner);
        guitarist = new Guitarist("hidden_uri", "contract_uri");
        vm.stopPrank();
    }

    function testFunctionCallHandling() public {
        console.log("--- BEFORE-Trigger Function Call ---");
        console.log("Starting call that should revert...");
        
        vm.startPrank(owner);
        console.log("--- Trigger Function Call ---");
        console.log("Executing with expected revert: Address: low-level call failed");
        vm.expectRevert("Address: low-level call failed");
        (bool success,) = address(guitarist).call(
            abi.encodeWithSignature(
                "functionCall(address,bytes)",
                nonContract,
                mockData
            )
        );

        console.log("--- AFTER-Trigger Function Call ---");
        require(!success, "Call should fail");
        console.log("Result: Call reverted as expected with target error message");
        vm.stopPrank();

        console.log("Vulnerability not Exist: Function call reverts correctly with expected error when call fails");
    }

    function testFunctionCallWithErrorRecovery() public {
        console.log("--- BEFORE-Trigger Function Call ---");
        console.log("Starting call that should revert...");
        
        vm.startPrank(owner);
        console.log("--- Trigger Error Preparation ---");
        vm.mockCallRevert(
            nonContract,
            mockData,
            "custom_error"
        );

        console.log("--- Trigger Function Call ---");
        console.log("Executing with expected revert: custom_error");
        vm.expectRevert("custom_error");
        (bool success,) = address(guitarist).call(
            abi.encodeWithSignature(
                "functionCall(address,bytes,string)",
                nonContract,
                mockData,
                "forwarded_error"
            )
        );

        console.log("--- AFTER-Trigger Function Call ---");
        require(!success, "Call should revert");
        console.log("Result: Call reverted as expected with custom error");
        vm.stopPrank();

        console.log("Vulnerability not Exist: Function call propagates custom errors correctly");
    }
}