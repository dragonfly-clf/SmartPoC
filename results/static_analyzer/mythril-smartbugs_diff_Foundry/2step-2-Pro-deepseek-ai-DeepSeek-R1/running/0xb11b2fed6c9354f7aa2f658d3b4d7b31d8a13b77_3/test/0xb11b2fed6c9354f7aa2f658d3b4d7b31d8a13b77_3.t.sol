// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb11b2fed6c9354f7aa2f658d3b4d7b31d8a13b77.sol";

contract DepositProxyTest is Test {
    DepositProxy proxy;
    address owner = address(0xA);
    address attacker = address(0xB);
    address maxAddress = address(type(uint160).max);
    bool step1Success;
    bool step2Success;

    function setUp() public {
        vm.startPrank(owner);
        proxy = new DepositProxy{value: 0}();
        vm.stopPrank();
    }

    function test_NoUnderflowWithMaxAddress() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Testing ownership transfers with maxAddress...");

        console.log("--- Trigger Step 1: Transfer owner -> maxAddress ---");
        vm.startPrank(owner);
        (step1Success, ) = address(proxy).call(
            abi.encodeWithSignature("transferOwner(address)", maxAddress)
        );
        vm.stopPrank();
        console.log("Step1 call %s", step1Success ? "did not revert" : "reverted");

        console.log("--- Trigger Step 2: Transfer maxAddress -> attacker ---");
        vm.prank(maxAddress);
        (step2Success, ) = address(proxy).call(
            abi.encodeWithSignature("transferOwner(address)", attacker)
        );
        console.log("Step2 call %s", step2Success ? "did not revert" : "reverted");

        console.log("--- AFTER-Trigger ---");
        
        if (step1Success && step2Success) {
            console.log("Vulnerability Exists: Both transfers executed without revert when using maxAddress");
        } else {
            console.log("Vulnerability not Exist: Transfers reverted at critical step");
        }
    }
}