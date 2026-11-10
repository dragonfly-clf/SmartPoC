// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LUCKYRABBITSPIN.sol";

contract Reverter {
    fallback() external payable {
        revert();
    }
    receive() external payable {
        revert();
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }

    function WETH() external pure returns (address) {
        return address(0x456);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}

contract LUCKYRABBITSPINPTRPTest is Test {
    LUCKYRABBITSPIN token;
    Reverter reverter;
    address devAddress = address(0xBEEF);
    address marketingAddress = address(0xCAFE);
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY = 0x1234567890123456789012345678901234567890;

    function setUp() public {
        // Setup mocks for Uniswap
        MockRouter mockRouter = new MockRouter();
        vm.etch(ROUTER, address(mockRouter).code);
        
        MockFactory mockFactory = new MockFactory();
        vm.etch(FACTORY, address(mockFactory).code);

        // Deploy token
        vm.startPrank(devAddress);
        token = new LUCKYRABBITSPIN();
        vm.deal(address(token), 1 ether);
        vm.stopPrank();

        // Set addresses and deploy reverter
        reverter = new Reverter();
        vm.prank(devAddress);
        token.setNewMarketingAddress(payable(marketingAddress));
        vm.prank(devAddress);
        token.setNewDevAddress(payable(devAddress));
    }

    function testManualSendRevertWhenMarketingContractReverts() public {
        console.log("--- BEFORE-Trigger Action ---");
        // Set marketing address to contract that reverts
        vm.prank(devAddress);
        token.setNewMarketingAddress(payable(address(reverter)));
        console.log("Marketing address set to the reverting contract");

        console.log("--- Trigger: manualsend ---");
        // Attempt to send funds to fee addresses
        vm.prank(devAddress);
        (bool success, ) = address(token).call(abi.encodeWithSignature("manualsend()"));
        
        console.log("--- AFTER-Trigger Action ---");
        // Display exploit result
        if (!success) {
            console.log("Call REVERTED as expected");
            console.log("Vulnerability Exists: manualsend reverts when marketing address is reverting contract");
        } else {
            console.log("Call SUCCEEDED (no revert)");
            console.log("Vulnerability not Exist: manualsend handles reverting contract properly");
        }
    }

    function testManualSendRevertWhenDevContractReverts() public {
        console.log("--- BEFORE-Trigger Action ---");
        // Set development address to contract that reverts
        vm.prank(devAddress);
        token.setNewDevAddress(payable(address(reverter)));
        console.log("Dev address set to the reverting contract");

        console.log("--- Trigger: manualsend ---");
        // Attempt to send funds to fee addresses
        vm.prank(devAddress);
        (bool success, ) = address(token).call(abi.encodeWithSignature("manualsend()"));
        
        console.log("--- AFTER-Trigger Action ---");
        // Display exploit result
        if (!success) {
            console.log("Call REVERTED as expected");
            console.log("Vulnerability Exists: manualsend reverts when dev address is reverting contract");
        } else {
            console.log("Call SUCCEEDED (no revert)");
            console.log("Vulnerability not Exist: manualsend handles reverting contract properly");
        }
    }
}