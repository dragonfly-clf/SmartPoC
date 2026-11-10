// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

contract MockToken {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return true;
    }
}

contract DenialOfServiceTest is Test {
    demo public myDemo;
    MockToken public mockToken;

    function setUp() public {
        myDemo = new demo();
        mockToken = new MockToken();
    }

    function test_denialOfServiceViaLargeBatch() public {
        uint arraySize = 10000;
        address[] memory tos = new address[](arraySize);

        for (uint256 i = 0; i < arraySize; i++) {
            tos[i] = address(uint160(i + 10000)); 
        }

        console2.log("--- BEFORE-TRIGGER ---");
        console2.log("Gas provided: 5,000,000");
        console2.log("Batch size: ", arraySize);

        console2.log("--- TRIGGER: large batch transfer ---");
        (bool success, ) = address(myDemo).call{gas: 5_000_000}(
            abi.encodeWithSelector(
                demo.transfer.selector,
                address(this),
                address(mockToken),
                tos,
                100
            )
        );

        console2.log("--- AFTER-TRIGGER ---");
        console2.log("Transaction status: ", success ? "Success" : "Revert");

        if (!success) {
            console2.log("Vulnerability Exists: Transaction reverted due to excessive gas consumption with large batch");
        } else {
            console2.log("Vulnerability not Exist: Transaction succeeded with large batch and limited gas");
        }
    }
}