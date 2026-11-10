// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FidoMeta.sol";

contract FidometaAddressTest is Test {
    Fidometa public fidometa;
    address public tokenOwner;
    address public eoaAddress = address(0x123456);

    function setUp() public {
        tokenOwner = vm.addr(1);
        vm.startPrank(tokenOwner);
        fidometa = new Fidometa();
        vm.stopPrank();
    }

    function testUnlockWithEOA() public {
        console.log("--- Trigger unlock with EOA ---");
        vm.prank(tokenOwner);
        vm.expectRevert();
        fidometa.unlock(eoaAddress);
        
        console.log("Vulnerability not Exist: unlock function reverts when called with EOA as expected");
    }

    function testUnlockWithContractThatReverts() public {
        MockRevert mock = new MockRevert();
        console.log("--- Trigger unlock with reverting contract ---");
        vm.prank(tokenOwner);
        vm.expectRevert();
        fidometa.unlock(address(mock));
        
        console.log("Vulnerability not Exist: unlock function reverts when called with reverting contract as expected");
    }
}

contract MockRevert {
    fallback() external payable {
        revert("Forced revert");
    }
}