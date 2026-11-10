// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KLingToken.sol";

contract MockBEP20Fail {
    mapping(address => uint256) public balanceOf;

    function transfer(address, uint256) external pure returns (bool) {
        return false; // Always transfer fails
    }

    function mint(address account, uint256 amount) external {
        balanceOf[account] += amount; // Set initial balance for testing
    }
}

contract KLingTokenTest is Test {
    KLingToken token;
    MockBEP20Fail mockToken;
    address owner = makeAddr("owner");
    address recipient = makeAddr("recipient");
    uint256 amount = 1 ether;

    function setUp() public {
        vm.prank(owner);
        token = new KLingToken(address(0)); // Deploy real contract
        
        mockToken = new MockBEP20Fail();    // Deploy mock token that always fails
        mockToken.mint(address(token), amount); // Fund token contract with mock tokens
    }

    function test_adminEmergencyIgnoresFailedBEP20Transfer() public {
        console.log("--- BEFORE EMERGENCY OPERATION ---");
        uint256 beforeContractBalance = mockToken.balanceOf(address(token));
        uint256 beforeRecipientBalance = mockToken.balanceOf(recipient);
        console.log("Token contract balance:", beforeContractBalance);
        console.log("Recipient balance:", beforeRecipientBalance);

        console.log("--- TRIGGER: adminEmergency (should fail silently) ---");
        vm.prank(owner);
        token.adminEmergency(address(mockToken), recipient, amount); // Critical call

        console.log("--- AFTER EMERGENCY OPERATION ---");
        uint256 afterContractBalance = mockToken.balanceOf(address(token));
        uint256 afterRecipientBalance = mockToken.balanceOf(recipient);
        console.log("Token contract balance:", afterContractBalance);
        console.log("Recipient balance:", afterRecipientBalance);

        // Final verdict logic
        bool balanceUnchanged = (beforeContractBalance == afterContractBalance) && 
                               (beforeRecipientBalance == afterRecipientBalance);
        console.log("Balances unchanged:", balanceUnchanged);
        
        if(balanceUnchanged) {
            console.log("Vulnerability Exists: The function did not revert on failed transfer and ignored the error");
        } else {
            console.log("Vulnerability not Exist: Balances changed despite failed transfer");
        }
    }
}