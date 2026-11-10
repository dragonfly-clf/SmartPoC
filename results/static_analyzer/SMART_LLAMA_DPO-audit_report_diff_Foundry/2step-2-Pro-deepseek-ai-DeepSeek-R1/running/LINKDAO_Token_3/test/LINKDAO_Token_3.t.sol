// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LINKDAO_Token.sol";

contract LinkDaoTokenTest is Test {
    LINKDAO_Token token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address constant ZERO_ADDRESS = address(0);

    function setUp() public {
        vm.startPrank(owner);
        token = new LINKDAO_Token();
        token.mint(owner, 1000 ether);
        vm.stopPrank();
    }

    function testTransferToZeroAddress() public {
        vm.startPrank(owner);
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialZeroAddressBalance = token.balanceOf(ZERO_ADDRESS);
        uint256 initialTotalSupply = token.totalSupply();
        console.log("Owner Balance:", initialOwnerBalance);
        console.log("Zero Address Balance:", initialZeroAddressBalance);
        console.log("Total Supply:", initialTotalSupply);
        
        console.log("--- Trigger Operation: Transfer to Zero Address ---");
        try token.transfer(ZERO_ADDRESS, 100 ether) {
            console.log("Operation completed without revert");
        } catch (bytes memory) {
            console.log("Operation reverted");
        }
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalOwnerBalance = token.balanceOf(owner);
        uint256 finalZeroAddressBalance = token.balanceOf(ZERO_ADDRESS);
        uint256 finalTotalSupply = token.totalSupply();
        console.log("Owner Balance:", finalOwnerBalance);
        console.log("Zero Address Balance:", finalZeroAddressBalance);
        console.log("Total Supply:", finalTotalSupply);
        
        console.log("--- Comparison ---");
        bool stateChanged = (initialOwnerBalance != finalOwnerBalance) ||
                            (initialZeroAddressBalance != finalZeroAddressBalance) ||
                            (initialTotalSupply != finalTotalSupply);
        
        if(stateChanged) {
            console.log("Vulnerability Exists: Transfer to zero address succeeded and state changed");
        } else {
            console.log("Vulnerability not Exist: Transfer to zero address was blocked");
        }
        vm.stopPrank();
    }

    function testTransferFromToZeroAddress() public {
        vm.startPrank(owner);
        token.approve(user1, 100 ether);
        vm.stopPrank();
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialZeroAddressBalance = token.balanceOf(ZERO_ADDRESS);
        uint256 initialTotalSupply = token.totalSupply();
        console.log("Owner Balance:", initialOwnerBalance);
        console.log("Zero Address Balance:", initialZeroAddressBalance);
        console.log("Total Supply:", initialTotalSupply);
        
        console.log("--- Trigger Operation: TransferFrom to Zero Address ---");
        vm.startPrank(user1);
        try token.transferFrom(owner, ZERO_ADDRESS, 100 ether) {
            console.log("Operation completed without revert");
        } catch (bytes memory) {
            console.log("Operation reverted");
        }
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalOwnerBalance = token.balanceOf(owner);
        uint256 finalZeroAddressBalance = token.balanceOf(ZERO_ADDRESS);
        uint256 finalTotalSupply = token.totalSupply();
        console.log("Owner Balance:", finalOwnerBalance);
        console.log("Zero Address Balance:", finalZeroAddressBalance);
        console.log("Total Supply:", finalTotalSupply);
        
        console.log("--- Comparison ---");
        bool stateChanged = (initialOwnerBalance != finalOwnerBalance) ||
                            (initialZeroAddressBalance != finalZeroAddressBalance) ||
                            (initialTotalSupply != finalTotalSupply);
        
        if(stateChanged) {
            console.log("Vulnerability Exists: TransferFrom to zero address succeeded and state changed");
        } else {
            console.log("Vulnerability not Exist: TransferFrom to zero address was blocked");
        }
    }

    function testMintToZeroAddress() public {
        vm.startPrank(owner);

        console.log("--- BEFORE-Trigger State ---");
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialZeroAddressBalance = token.balanceOf(ZERO_ADDRESS);
        uint256 initialTotalSupply = token.totalSupply();
        console.log("Owner Balance:", initialOwnerBalance);
        console.log("Zero Address Balance:", initialZeroAddressBalance);
        console.log("Total Supply:", initialTotalSupply);
        
        console.log("--- Trigger Operation: Mint to Zero Address ---");
        try token.mint(ZERO_ADDRESS, 100 ether) {
            console.log("Operation completed without revert");
        } catch (bytes memory) {
            console.log("Operation reverted");
        }
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalOwnerBalance = token.balanceOf(owner);
        uint256 finalZeroAddressBalance = token.balanceOf(ZERO_ADDRESS);
        uint256 finalTotalSupply = token.totalSupply();
        console.log("Owner Balance:", finalOwnerBalance);
        console.log("Zero Address Balance:", finalZeroAddressBalance);
        console.log("Total Supply:", finalTotalSupply);
        
        console.log("--- Comparison ---");
        bool stateChanged = (initialOwnerBalance != finalOwnerBalance) ||
                            (initialZeroAddressBalance != finalZeroAddressBalance) ||
                            (initialTotalSupply != finalTotalSupply);
        
        if(stateChanged) {
            console.log("Vulnerability Exists: Mint to zero address succeeded and state changed");
        } else {
            console.log("Vulnerability not Exist: Mint to zero address was blocked");
        }
        vm.stopPrank();
    }
}