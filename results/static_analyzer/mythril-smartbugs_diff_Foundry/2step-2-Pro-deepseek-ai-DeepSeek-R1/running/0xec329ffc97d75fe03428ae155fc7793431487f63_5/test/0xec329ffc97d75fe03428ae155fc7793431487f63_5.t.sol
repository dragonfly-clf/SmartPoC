// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xec329ffc97d75fe03428ae155fc7793431487f63.sol";

contract TokenSenderTest is Test {
    TokenSender tokenSender;
    address owner = makeAddr("owner");
    address externalContract = makeAddr("externalContract");
    
    function convertWei(uint256 amountWei) internal pure returns (string memory) {
        return string(abi.encodePacked(vm.toString(amountWei), " wei"));
    }

    function setUp() public {
        vm.startPrank(owner);
        tokenSender = new TokenSender(address(0));
        vm.stopPrank();
    }

    function testExecuteUnderflow() public {
        // Fund contract with minimal ETH
        vm.deal(address(tokenSender), 1 wei);
        bytes memory data = new bytes(0);

        // Pre-trigger state snapshot
        console2.log("--- BEFORE-Trigger State ---");
        string memory balanceBefore = convertWei(address(tokenSender).balance);
        console2.log("Contract balance:  %s", balanceBefore);
        
        console2.log("--- Trigger execute ---");
        vm.prank(owner);

        (bool success, ) = address(tokenSender).call(
            abi.encodeWithSignature(
                "execute(address,uint256,bytes)",
                externalContract,
                1000 wei,
                data
            )
        );
        console2.log("--- AFTER-Trigger State ---");
        string memory balanceAfter = convertWei(address(tokenSender).balance);
        console2.log("Contract balance:  %s", balanceAfter);
        console2.log("Transaction status: %s", success ? "SUCCESS" : "REVERTED");
        
        if (success || address(tokenSender).balance != 1 wei) {
            console2.log("Vulnerability Exists: Contract allowed transfer beyond balance without revert");
        } else {
            console2.log("Vulnerability not Exist: Contract reverted as expected on underflow");
        }
    }
}