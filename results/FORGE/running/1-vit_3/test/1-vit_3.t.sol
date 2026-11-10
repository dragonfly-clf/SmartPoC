// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TokenTool.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
    
    function WETH() external pure returns (address) {
        return address(0);
    }
}

contract TokenToolBlacklistTest is Test {
    TokenTool token;
    address owner = address(0x100);
    address marketingAddress = address(0x400);
    address teamAddress = address(0x500);
    address serviceAddress = address(0x600);
    address user1 = address(0x201);
    address user2 = address(0x202);
    uint256 constant TEST_AMOUNT = 1 ether;

    function setUp() public {
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        MockUniswapV2Router mockRouter = new MockUniswapV2Router(address(mockFactory));
        
        token = new TokenTool(
            "TestToken",
            "TT",
            18,
            1000000,
            address(mockRouter),
            owner,
            marketingAddress,
            teamAddress,
            serviceAddress
        );
        
        // Fund test addresses
        vm.prank(owner);
        token.transfer(address(this), 100 ether);
        
        // Fund test users
        token.transfer(user1, 10 ether);
    }

    function testBlacklistedSender() public {
        console.log("\n--- BEFORE Blacklist Attempt ---");
        console.log("Performing valid transfer (unblacklisted sender)");
        uint256 senderStartBal = token.balanceOf(user1);
        uint256 recipientStartBal = token.balanceOf(owner);
        console.log("Sender balance before: ", senderStartBal);
        console.log("Recipient balance before: ", recipientStartBal);

        // Valid transfer before blacklisting
        vm.prank(user1);
        token.transfer(owner, TEST_AMOUNT);

        uint256 senderMidBal = token.balanceOf(user1);
        uint256 recipientMidBal = token.balanceOf(owner);
        console.log("Sender balance after transfer: ", senderMidBal);
        console.log("Recipient balance after transfer: ", recipientMidBal);

        // Blacklist the sender
        console.log("\n--- Trigger Blacklist Action ---");
        address[] memory addresses = new address[](1);
        addresses[0] = user1;
        vm.prank(owner);
        token.multipleBotlistAddress(addresses, true);

        // Attempt transfer after blacklisting
        console.log("\n--- Test Blacklisted Sender ---");
        console.log("Attempting transfer from blacklisted sender");
        uint256 senderPreAttBalance = token.balanceOf(user1);
        uint256 recipientPreAttBalance = token.balanceOf(owner);
        console.log("Sender balance before attempt: ", senderPreAttBalance);
        console.log("Recipient balance before attempt: ", recipientPreAttBalance);

        vm.prank(user1);
        vm.expectRevert("Blacklisted address");
        token.transfer(owner, TEST_AMOUNT);
        
        // Post-transfer state check
        uint256 senderPostBalance = token.balanceOf(user1);
        uint256 recipientPostBalance = token.balanceOf(owner);
        console.log("Sender balance after attempt: ", senderPostBalance);
        console.log("Recipient balance after attempt: ", recipientPostBalance);

        // Final verdict
        console.log("\n--- Vulnerability Verification ---");
        bool fundsFrozen = (senderPostBalance == senderPreAttBalance) && 
                          (recipientPostBalance == recipientPreAttBalance);
        if (fundsFrozen) {
            console.log("Blacklist prevents transfers from sender as intended");
            console.log("Vulnerability Exists: Owner can freeze user funds via blacklist");
        } else {
            console.log("Transfer succeeded unexpectedly after blacklist");
            console.log("Vulnerability not Exist: Blacklist fails to block sender");
        }
    }

    function testBlacklistedRecipient() public {
        console.log("\n--- BEFORE Blacklist Attempt ---");
        console.log("Performing valid transfer (unblacklisted recipient)");
        uint256 senderStartBal = token.balanceOf(address(this));
        uint256 recipientStartBal = token.balanceOf(user2);
        console.log("Sender balance before: ", senderStartBal);
        console.log("Recipient balance before: ", recipientStartBal);

        // Valid transfer before blacklisting
        token.transfer(user2, TEST_AMOUNT);

        uint256 senderMidBal = token.balanceOf(address(this));
        uint256 recipientMidBal = token.balanceOf(user2);
        console.log("Sender balance after transfer: ", senderMidBal);
        console.log("Recipient balance after transfer: ", recipientMidBal);

        // Blacklist the recipient
        console.log("\n--- Trigger Blacklist Action ---");
        address[] memory addresses = new address[](1);
        addresses[0] = user2;
        vm.prank(owner);
        token.multipleBotlistAddress(addresses, true);

        // Attempt transfer after blacklisting
        console.log("\n--- Test Blacklisted Recipient ---");
        console.log("Attempting transfer to blacklisted recipient");
        uint256 senderPreAttBalance = token.balanceOf(address(this));
        uint256 recipientPreAttBalance = token.balanceOf(user2);
        console.log("Sender balance before attempt: ", senderPreAttBalance);
        console.log("Recipient balance before attempt: ", recipientPreAttBalance);

        vm.expectRevert("Blacklisted address");
        token.transfer(user2, TEST_AMOUNT);
        
        // Post-transfer state check
        uint256 senderPostBalance = token.balanceOf(address(this));
        uint256 recipientPostBalance = token.balanceOf(user2);
        console.log("Sender balance after attempt: ", senderPostBalance);
        console.log("Recipient balance after attempt: ", recipientPostBalance);

        // Final verdict
        console.log("\n--- Vulnerability Verification ---");
        bool fundsProtected = (senderPostBalance == senderPreAttBalance) && 
                             (recipientPostBalance == recipientPreAttBalance);
        if (fundsProtected) {
            console.log("Blacklist prevents transfers to recipient as intended");
            console.log("Vulnerability Exists: Owner can block funds sent to blacklisted address");
        } else {
            console.log("Transfer succeeded unexpectedly after blacklist");
            console.log("Vulnerability not Exist: Blacklist fails to block recipient");
        }
    }
}