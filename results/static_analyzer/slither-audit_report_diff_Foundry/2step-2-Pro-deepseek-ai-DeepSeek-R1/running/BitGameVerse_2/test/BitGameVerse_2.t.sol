// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BitGameVerse.sol";

contract BadERC20 {
    function transfer(address, uint256) external pure returns (bool) {
        return false; // Always fail transfers
    }
}

contract BitGameVerseUncheckedTransferTest is Test {
    BitGameVerse token;
    BadERC20 badToken;
    address owner = address(0x1);
    address receiver = address(0x2);

    function setUp() public {
        vm.prank(owner);
        
        // Setup mock router
        address mockRouter = address(new MockRouter());
        
        // Deploy BitGameVerse with mock router
        token = new BitGameVerse(mockRouter);
        
        // Deploy bad ERC20 token
        badToken = new BadERC20();
    }

    function test_UncheckedTransferFailure() public {
        uint256 testAmount = 100 ether;
        
        console.log("--- BEFORE-Trigger ---");
        console.log("Status: Preparing to validate unchecked transfer vulnerability");
        
        console.log("--- Trigger rescueAnyBEP20Tokens ---");
        bool success;
        try token.rescueAnyBEP20Tokens(address(badToken), receiver, testAmount) {
            success = true;
        } catch {
            success = false;
        }
        
        console.log("--- AFTER-Trigger ---");
        console.log("Result: Function call %s", success ? "succeeded without reverting" : "reverted on failed transfer");
        
        if (success) {
            console.log("Vulnerability Exists: The rescue function completed execution despite external transfer failure");
        } else {
            console.log("Vulnerability not Exist: Function correctly reverts on failed transfers");
            revert("Expected vulnerability behavior not observed");
        }
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockWETH {
    // Empty mock WETH contract
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor() {
        factory = address(new MockFactory());
        WETH = address(new MockWETH());
    }
}