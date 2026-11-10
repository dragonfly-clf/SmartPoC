// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AIOToken.sol";

contract MockPancakeFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract AIOTokenZeroAddressTest is Test {
    AIOToken token;
    address owner = address(0x1);
    address alice = address(0x2);
    address zero = address(0);

    function setUp() public {
        // Deploy mock factory and simulate hardcoded addresses
        MockPancakeFactory mockFactory = new MockPancakeFactory();
        address factoryAddr = 0xcA143Ce32Fe78f1f7019d7d551a6402fC5350c73;
        address wbnbAddr = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        
        // Use vm.etch to set bytecode at hardcoded addresses
        vm.etch(factoryAddr, address(mockFactory).code);
        vm.etch(wbnbAddr, hex"00"); // Empty contract bytecode

        vm.startPrank(owner);
        token = new AIOToken();
        vm.stopPrank();
    }

    function testTransferToZeroReverts() public {
        uint256 ownerInitialBalance = token.balanceOf(owner);
        uint256 amount = 5e16; // 0.05 tokens - within initial supply
        
        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 zeroBalanceBefore = token.balanceOf(zero);
        console.log("Owner balance before:", ownerBalanceBefore);
        console.log("Zero address balance before:", zeroBalanceBefore);

        console.log("--- Trigger Transfer ---");
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", zero, amount)
        );
        console.log("Transfer result:", success ? "Success" : "Reverted");
        
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 zeroBalanceAfter = token.balanceOf(zero);
        console.log("Owner balance after:", ownerBalanceAfter);
        console.log("Zero address balance after:", zeroBalanceAfter);
        
        // Validate state changes and vulnerability
        bool vulnerable = false;
        bool stateChanged = false;
        string memory reason;
        
        if (success) {
            if ((ownerBalanceAfter < ownerBalanceBefore) && (zeroBalanceAfter > zeroBalanceBefore)) {
                vulnerable = true;
                stateChanged = true;
                reason = "Transfer to zero succeeded";
            } else {
                stateChanged = false;
                reason = "Transaction succeeded but state unchanged";
            }
        } else {
            if ((ownerBalanceAfter == ownerBalanceBefore) && (zeroBalanceAfter == zeroBalanceBefore)) {
                vulnerable = false;
                stateChanged = false;
                reason = "Transaction reverted & state unchanged";
            } else {
                vulnerable = true;
                stateChanged = true;
                reason = "Transaction reverted but state changed";
            }
        }
        
        console.log("Vulnerability verdict:");
        if (vulnerable) {
            console.log(reason);
            console.log("Vulnerability Exists: Transfer to zero address possible");
        } else {
            console.log(reason);
            console.log("Vulnerability not Exist: Revert protection functional");
        }
    }

    function testTransferFromToZeroReverts() public {
        uint256 amount = 5e16; // 0.05 tokens
        uint256 allowance = 1e17; // 0.1 tokens
        
        // Setup approval
        vm.prank(owner);
        token.approve(alice, allowance);
        
        console.log("--- BEFORE-Trigger TransferFrom ---");
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 zeroBalanceBefore = token.balanceOf(zero);
        console.log("Owner balance before:", ownerBalanceBefore);
        console.log("Zero address balance before:", zeroBalanceBefore);
        console.log("Allowance before:", token.allowance(owner, alice));

        console.log("--- Trigger TransferFrom ---");
        vm.prank(alice);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", owner, zero, amount)
        );
        console.log("TransferFrom result:", success ? "Success" : "Reverted");
        
        console.log("--- AFTER-Trigger TransferFrom ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 zeroBalanceAfter = token.balanceOf(zero);
        console.log("Owner balance after:", ownerBalanceAfter);
        console.log("Zero address balance after:", zeroBalanceAfter);
        console.log("Allowance after:", token.allowance(owner, alice));
        
        // Validate state changes and vulnerability
        bool vulnerable = false;
        bool stateChanged = false;
        string memory reason;
        
        if (success) {
            if ((ownerBalanceAfter < ownerBalanceBefore) && (zeroBalanceAfter > zeroBalanceBefore)) {
                vulnerable = true;
                stateChanged = true;
                reason = "TransferFrom to zero succeeded";
            } else {
                stateChanged = false;
                reason = "Transaction succeeded but state unchanged";
            }
        } else {
            if ((ownerBalanceAfter == ownerBalanceBefore) && (zeroBalanceAfter == zeroBalanceBefore)) {
                vulnerable = false;
                stateChanged = false;
                reason = "Transaction reverted & state unchanged";
            } else {
                vulnerable = true;
                stateChanged = true;
                reason = "Transaction reverted but state changed";
            }
        }
        
        console.log("Vulnerability verdict:");
        if (vulnerable) {
            console.log(reason);
            console.log("Vulnerability Exists: TransferFrom to zero address possible");
        } else {
            console.log(reason);
            console.log("Vulnerability not Exist: Revert protection functional");
        }
    }
}