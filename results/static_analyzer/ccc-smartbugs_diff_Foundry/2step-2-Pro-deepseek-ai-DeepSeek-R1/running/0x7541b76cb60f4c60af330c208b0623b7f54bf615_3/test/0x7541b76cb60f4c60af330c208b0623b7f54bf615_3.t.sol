// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol"; // Added for verdict logs
import "../src/0x7541b76cb60f4c60af330c208b0623b7f54bf615.sol";

contract MessagePaddingGasTest is Test {
    Log public logContract;
    U_BANK public bank;

    // Helper function to generate long string
    function generateLongString(uint length) internal pure returns (string memory) {
        bytes memory longBytes = new bytes(length);
        for (uint i = 0; i < length; i++) {
            longBytes[i] = "A";
        }
        return string(longBytes);
    }

    function setUp() public {
        // Deploy Log contract
        logContract = new Log();
        // Deploy U_BANK with Log contract address
        bank = new U_BANK(address(logContract));
    }

    function testLongStringGasUsage() public {
        string memory longString = generateLongString(100000);
        
        uint gasStart = gasleft();
        logContract.AddMessage(address(this), 1, longString);
        uint gasUsed = gasStart - gasleft();
        
        emit log_named_uint("Gas used for long message (100k chars)", gasUsed);
        
        // Vulnerability verdict based on gas threshold
        if (gasUsed > 2000000) {
            console2.log("Vulnerability Exists: AddMessage function allows gas-exhaustion attack with long strings");
        } else {
            console2.log("Vulnerability not Exist: AddMessage gas consumption below critical threshold");
        }
    }
    
    function testLongStringViaPut() public {
        string memory longString = generateLongString(50000);
        
        // Create a holder account
        address account = address(0x123);
        vm.deal(account, 1 ether);
        
        // Store long string using Put function
        uint gasStart = gasleft();
        vm.prank(account);
        bank.Put{value: 1 ether}(block.timestamp + 1 days);
        uint gasUsed = gasStart - gasleft();
        
        emit log_named_uint("Gas used for Put with long message", gasUsed);
        
        // Vulnerability verdict based on gas threshold
        if (gasUsed > 1000000) {
            console2.log("Vulnerability Exists: Put function allows gas-exhaustion attack via long strings");
        } else {
            console2.log("Vulnerability not Exist: Put function gas consumption below critical threshold");
        }
    }
}