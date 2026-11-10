// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WEEDVERSESTRAINS.sol";

contract MockToken {
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract WEEDVERSESTRAINSTest is Test {
    WEEDVERSESTRAINS token;
    MockToken mockToken;
    address owner = makeAddr("owner");

    function setUp() public {
        // Mock the Uniswap router calls used in the constructor
        address ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(this))
        );
        
        vm.mockCall(
            address(this),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(makeAddr("pair"))
        );
        
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(makeAddr("weth"))
        );

        vm.startPrank(owner);
        token = new WEEDVERSESTRAINS();
        mockToken = new MockToken();
        vm.stopPrank();
    }

    function testUncheckedTransfer() public {
        bool vulnerable;
        console.log("--- BEFORE-Trigger ---");
        // There are no state variables to verify before the attack
        
        console.log("--- Trigger rescuetokens ---");
        vm.startPrank(owner);
        try token.rescuetokens(address(mockToken), 100) {
            // Successful call without revert indicates vulnerability
            vulnerable = true;
            console.log("rescuetokens call: DID NOT REVERT");
        } catch {
            // Revert indicates proper failure handling (no vulnerability)
            vulnerable = false;
            console.log("rescuetokens call: REVERTED");
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        // Final verdict based on revert status
        if (vulnerable) {
            console.log("Vulnerability confirmed: Transfer failure not handled");
            console.log("Vulnerability Exists: rescuetokens doesn't revert on failed transfer");
        } else {
            console.log("Vulnerability not detected: Transfer failure handled properly");
            console.log("Vulnerability not Exist: rescuetokens reverts on failed transfer");
        }
    }
}