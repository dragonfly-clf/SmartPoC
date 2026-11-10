// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ERC20.sol";

contract ContractRecipient {
    fallback() external payable {}
}

contract ERC20Test is Test {
    ERC20 token;
    ContractRecipient contractRecipient;

    address user = makeAddr("user");
    uint256 initialSupply = 1000 ether;

    function setUp() public {
        token = new ERC20(initialSupply);
        contractRecipient = new ContractRecipient();
    }

    function testTransferToContract() public {
        // Get initial balance of contract recipient
        uint256 beforeBal = token.balanceOf(address(contractRecipient));
        console.log("--- BEFORE-Trigger Balance ---");
        console.log("Contract recipient balance:", beforeBal);

        console.log("--- Trigger Transfer ---");
        // Perform transfer to contract address
        vm.startPrank(address(this));
        token.transfer(address(contractRecipient), 100);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Balance ---");
        // Get balance after transfer and calculate difference
        uint256 afterBal = token.balanceOf(address(contractRecipient));
        uint256 diff = afterBal - beforeBal;
        console.log("Contract recipient balance:", afterBal);
        console.log("Balance difference:", diff);
        
        // Verify transfer success via balance change
        assertEq(afterBal, 100, "Contract should have received 100 tokens");
        
        // Vulnerability verdict
        if (diff == 100) {
            console.log("Vulnerability Exists: Tokens successfully transferred to contract lacking tokenFallback");
        } else {
            console.log("Vulnerability not Exist: Tokens not transferred as expected");
        }
    }

    function testTransferFromToContract() public {
        // Setup initial tokens and approval
        token.transfer(user, 500);
        vm.prank(user);
        token.approve(address(this), 300);

        // Get initial balance of contract recipient
        uint256 beforeBal = token.balanceOf(address(contractRecipient));
        console.log("--- BEFORE-Trigger Balance ---");
        console.log("Contract recipient balance:", beforeBal);

        console.log("--- Trigger TransferFrom ---");
        // Perform transferFrom to contract address
        token.transferFrom(user, address(contractRecipient), 100);
        
        console.log("--- AFTER-Trigger Balance ---");
        // Get balance after transfer and calculate difference
        uint256 afterBal = token.balanceOf(address(contractRecipient));
        uint256 diff = afterBal - beforeBal;
        console.log("Contract recipient balance:", afterBal);
        console.log("Balance difference:", diff);
        
        // Verify transfer success via balance change
        assertEq(afterBal, 100, "Contract should have received 100 tokens");
        
        // Vulnerability verdict
        if (diff == 100) {
            console.log("Vulnerability Exists: Tokens successfully transferred to contract lacking tokenFallback");
        } else {
            console.log("Vulnerability not Exist: Tokens not transferred as expected");
        }
    }
}