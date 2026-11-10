// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyApeCoin.sol";

contract BabyApeCoinTest is Test {
    BabyApeCoin token;
    address owner = address(0x1);
    address user = address(0x2);

    function setUp() public {
        vm.prank(owner);
        token = new BabyApeCoin();
        
        // Mint tokens to test with
        vm.prank(owner);
        token.mint(owner, 1000 ether);
    }

    // Helper to check if address is contract (needed for Solidity 0.7.6)
    function isContract(address _addr) internal view returns (bool) {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function testFunctionCallToNonContract() public {
        vm.startPrank(owner);

        // Prepare call data
        bytes memory data = abi.encodeWithSignature("doesNotExist()");
        bytes memory functionCallData = abi.encodeWithSignature(
            "functionCall(address,bytes)",
            user,
            data
        );
        
        console.log("--- BEFORE-Trigger ---");
        console.log("");
        console.log("Parameters:");
        console.log("Token address: ");
        console.log(address(token));
        console.log("Target address: ");
        console.log(user);
        if (isContract(user)) {
            console.log("Target is contract? Yes");
        } else {
            console.log("Target is contract? No");
        }
        console.log("Call data length: ");
        console.log(uint(functionCallData.length));

        console.log("");
        console.log("--- Trigger ---");
        console.log("Executing functionCall...");
        (bool success, bytes memory returnData) = address(token).call(
            functionCallData
        );
        console.log("Call completed. Success: ");
        console.log(success);
        if (!success) {
            console.log("Error data length: ");
            console.log(uint(returnData.length));
        }
        
        console.log("");
        console.log("--- AFTER-Trigger ---");
        
        // Determine vulnerability existence
        if (success) {
            console.log("Vulnerability Exists: Token allows unsafe functionCall to non-contract addresses");
        } else {
            console.log("Vulnerability not Exist: Token correctly rejects functionCall to non-contract addresses");
        }
        
        vm.stopPrank();
    }
}