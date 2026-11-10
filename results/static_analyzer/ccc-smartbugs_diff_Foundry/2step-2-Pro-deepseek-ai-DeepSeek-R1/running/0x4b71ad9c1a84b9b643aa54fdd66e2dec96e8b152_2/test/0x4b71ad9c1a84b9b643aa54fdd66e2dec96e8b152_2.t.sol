// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4b71ad9c1a84b9b643aa54fdd66e2dec96e8b152.sol";

contract MockToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return true;
    }
}

contract AirPortTransferOverflowTest is Test {
    airPort public airport;
    MockToken public token;
    address constant FROM = address(1);
    address constant TO_ADDR1 = address(0x444);
    address constant TO_ADDR2 = address(0x555);
    
    function setUp() public {
        airport = new airPort();
        token = new MockToken();
    }

    function test_userTokenTransfersOverflow() public {
        // Create recipients array
        address[] memory recipients = new address[](2);
        recipients[0] = TO_ADDR1;
        recipients[1] = TO_ADDR2;
        
        // Set v to max_uint256 / 2 + 1 to cause overflow on second iteration
        uint256 v = type(uint256).max / 2 + 1;
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 beforeUserTokenTransfers = airport.userTokenTransfers(FROM, address(token));
        uint256 beforeTotalTransfers = airport.totalTransfers(FROM);
        console2.log("userTokenTransfers before:", beforeUserTokenTransfers);
        console2.log("totalTransfers before:", beforeTotalTransfers);
        
        console2.log("--- Trigger Transfer (expect overflow revert) ---");
        // Expect arithmetic overflow panic (0x11)
        vm.expectRevert(abi.encodeWithSignature("Panic(uint256)", 0x11));
        
        airport.transfer(
            FROM,
            address(token),
            recipients,
            v
        );
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 afterUserTokenTransfers = airport.userTokenTransfers(FROM, address(token));
        uint256 afterTotalTransfers = airport.totalTransfers(FROM);
        console2.log("userTokenTransfers after:", afterUserTokenTransfers);
        console2.log("totalTransfers after:", afterTotalTransfers);
        
        console2.log("--- State Comparison Results ---");
        bool transfersUnchanged = (beforeUserTokenTransfers == afterUserTokenTransfers);
        bool totalsUnchanged = (beforeTotalTransfers == afterTotalTransfers);
        console2.log("userTokenTransfers unchanged?:", transfersUnchanged ? "YES" : "NO");
        console2.log("totalTransfers unchanged?:", totalsUnchanged ? "YES" : "NO");
        
        if (transfersUnchanged && totalsUnchanged) {
            console2.log("Vulnerability not Exist: State remains unchanged after overflow reverts");
        } else {
            console2.log("Vulnerability Exists: State changed despite overflow revert");
        }
    }
}