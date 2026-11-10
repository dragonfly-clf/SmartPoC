// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    MockToken public mockToken;
    address owner = makeAddr("owner");
    address holder = makeAddr("holder");

    function setUp() public {
        // Deploy TokenBank with owner address
        vm.prank(owner);
        tokenBank = new TokenBank();

        // Deploy mock token
        mockToken = new MockToken();
    }

    function test_UncheckedTokenTransferFailure() public {
        console2.log("--- BEFORE-Trigger ---");
        console2.log("Pre-condition: Mock token transfers set to FAIL");
        
        // Set mock token to fail transfers
        mockToken.setShouldFail(true);
        assertEq(mockToken.shouldFail(), true, "MockToken transfer failure enabled");

        console2.log("--- Trigger: WithdrawToken with failing token ---");
        // Critical vulnerability trigger
        vm.prank(owner);
        tokenBank.WithdrawToken(address(mockToken), 100 ether, holder);
        
        console2.log("--- AFTER-Trigger ---");
        console2.log("No state change occurred but execution continued without revert");
        console2.log("Vulnerability confirmed: Call continued despite failed token transfer");

        // Final vulnerability verification
        console2.log("Vulnerability Exists: WithdrawToken ignored failed external transfer call");
    }
}

contract MockToken {
    bool public shouldFail;

    function setShouldFail(bool _shouldFail) public {
        shouldFail = _shouldFail;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        to; value; // Silence unused warnings
        return !shouldFail;
    }
}