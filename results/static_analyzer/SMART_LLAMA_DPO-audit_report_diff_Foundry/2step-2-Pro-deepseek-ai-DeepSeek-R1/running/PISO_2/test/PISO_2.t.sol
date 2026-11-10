// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PISO.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract StartSaleDuplicateTest is Test {
    PISO token;
    address user1 = address(0x100);
    address user2 = address(0x200);
    uint256 tokenAmount;

    function setUp() public {
        // Create mock factory and router
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory), address(0x456));
        
        // Deploy token contract with mock router
        token = new PISO(address(router));
        
        // Set token amount accounting for decimals
        tokenAmount = 100 * 10 ** token.decimals();
    }

    function testDuplicateAddressesInSale() public {
        // Get initial balances BEFORE Trigger
        console.log("--- BEFORE-Trigger ---");
        uint256 initialBalUser1 = token.balanceOf(user1);
        uint256 initialBalUser2 = token.balanceOf(user2);
        uint256 initialBalOwner = token.balanceOf(address(this));
        console.log("User1 initial balance:", initialBalUser1);
        console.log("User2 initial balance:", initialBalUser2);
        console.log("Owner initial balance:", initialBalOwner);

        // Create array with duplicate addresses
        address[] memory receivers = new address[](3);
        receivers[0] = user1;
        receivers[1] = user2;
        receivers[2] = user1; // Duplicate address

        // Execute StartSale (Trigger)
        console.log("--- Trigger: StartSale ---");
        token.StartSale(receivers, tokenAmount);

        // Get final balances AFTER Trigger
        console.log("--- AFTER-Trigger ---");
        uint256 finalBalUser1 = token.balanceOf(user1);
        uint256 finalBalUser2 = token.balanceOf(user2);
        uint256 finalBalOwner = token.balanceOf(address(this));
        console.log("User1 final balance:", finalBalUser1);
        console.log("User2 final balance:", finalBalUser2);
        console.log("Owner final balance:", finalBalOwner);

        // Calculate balance changes
        uint256 diffUser1 = finalBalUser1 - initialBalUser1;
        uint256 diffUser2 = finalBalUser2 - initialBalUser2;
        uint256 diffOwner = initialBalOwner - finalBalOwner;

        // Verify vulnerability conditions
        bool user1DoubleTransfer = (diffUser1 == 2 * tokenAmount);
        bool user2SingleTransfer = (diffUser2 == tokenAmount);
        bool ownerBalanceCorrect = (diffOwner == 3 * tokenAmount);
        bool vulnerabilityExists = user1DoubleTransfer && user2SingleTransfer && ownerBalanceCorrect;

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Duplicate addresses received double tokens");
        } else {
            console.log("Vulnerability not Exist: Balance changes don't match duplicate transfer pattern");
        }
    }
}