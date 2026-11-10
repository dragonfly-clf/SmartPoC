// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LUCKYRABBITSPIN.sol";

contract BadToken {
    mapping(address => uint256) public balanceOf;

    // Transfer function that always returns false
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract RescueForeignTokensTest is Test {
    LUCKYRABBITSPIN public token;
    BadToken public badToken;
    address owner = makeAddr("owner");
    address recipient = makeAddr("recipient");
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Create valid mock addresses
        address mockFactory = address(0xFAC777);
        address mockWETH = address(0xDEAD77);
        address mockPair = address(0xBEEF77);
        
        // Mock router calls
        vm.mockCall(ROUTER, abi.encodeWithSignature("factory()"), abi.encode(mockFactory));
        vm.mockCall(ROUTER, abi.encodeWithSignature("WETH()"), abi.encode(mockWETH));
        vm.mockCall(mockFactory, abi.encodeWithSignature("createPair(address,address)"), abi.encode(mockPair));

        // Deploy contract
        token = new LUCKYRABBITSPIN();
        
        // Deploy bad token that returns false on transfer
        badToken = new BadToken();
        
        vm.stopPrank();
    }

    function test_rescueForeignTokensUncheckedReturn() public {
        // Prefund token contract with badTokens
        uint256 rescueAmount = 100 ether;
        deal(address(badToken), address(token), rescueAmount);

        vm.startPrank(owner);
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = badToken.balanceOf(address(token));
        uint256 recipientBalanceBefore = badToken.balanceOf(recipient);
        console.log("Token contract badToken balance:", contractBalanceBefore);
        console.log("Recipient badToken balance:", recipientBalanceBefore);

        console.log("--- Trigger rescueForeignTokens ---");
        // Attempt rescue tokens using token that returns false
        token.rescueForeignTokens(address(badToken), recipient, rescueAmount);
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = badToken.balanceOf(address(token));
        uint256 recipientBalanceAfter = badToken.balanceOf(recipient);
        console.log("Token contract badToken balance:", contractBalanceAfter);
        console.log("Recipient badToken balance:", recipientBalanceAfter);

        // Vulnerability verification
        bool unchanged = (contractBalanceAfter == contractBalanceBefore) && 
                         (recipientBalanceAfter == recipientBalanceBefore);
        
        if (unchanged) {
            console.log("Vulnerability Exists: Balances unchanged after failed transfer");
        } else {
            console.log("Vulnerability not Exist: Tokens were transferred successfully");
        }
        
        vm.stopPrank();
    }
}