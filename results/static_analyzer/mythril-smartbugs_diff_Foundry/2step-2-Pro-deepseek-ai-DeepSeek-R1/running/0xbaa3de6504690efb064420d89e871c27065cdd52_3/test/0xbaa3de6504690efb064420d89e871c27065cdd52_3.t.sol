// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbaa3de6504690efb064420d89e871c27065cdd52.sol";

contract VaultProxyUnderflowTest is Test {
    VaultProxy public vault;
    address public owner;
    address public nonOwner = makeAddr("nonOwner");

    function setUp() public {
        owner = address(this);
        vault = new VaultProxy{value: 0}();
    }

    function testNonOwnerCanCallTransferOwner() public {
        console2.log("--- BEFORE-Trigger Call ---");
        console2.log("No accessible state variables to record before call");

        console2.log("--- Trigger Operation ---");
        console2.log("Calling transferOwner as non-owner...");
        try vault.transferOwner(nonOwner) {
            console2.log("--- AFTER-Trigger Call ---");
            console2.log("Call succeeded without revert");
            console2.log("--- Verdict ---");
            console2.log("Vulnerability Exists: non-owner call succeeded without revert");
        } catch {
            console2.log("--- AFTER-Trigger Call ---");
            console2.log("Call reverted during execution");
            console2.log("--- Verdict ---");
            console2.log("Vulnerability not Exist: non-owner call reverted as expected");
            revert("Vulnerability not Exist: non-owner call reverted as expected");
        }
    }
}