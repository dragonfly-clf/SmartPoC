// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GREENWORLD.sol";

contract MaliciousToken {
    // Always returns false on transfer
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
    
    // Add balanceOf function that always returns 0
    function balanceOf(address) external pure returns (uint256) {
        return 0;
    }
}

contract GREENWORLDRescueTest is Test {
    GREENWORLD public token;
    MaliciousToken public maliciousToken;
    address owner = address(0x1);
    address receiver = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        maliciousToken = new MaliciousToken();
        
        // Deploy mocks for router dependencies
        address mockFactory = address(new MockFactory());
        address mockWETH = address(new MockWETH());
        address mockRouter = address(new MockRouter(mockFactory, mockWETH));
        
        // Deploy GREENWORLD token with mocked router
        token = new GREENWORLD(mockRouter);
        vm.stopPrank();
    }

    function testRescueTokenWithoutCheck() public {
        console.log("--- BEFORE-Trigger Rescue ---");
        uint256 beforeBalance = maliciousToken.balanceOf(receiver);
        console.log("Receiver malicious token balance (BEFORE):", beforeBalance);
        
        console.log("--- Trigger Rescue ---");
        vm.prank(owner);
        // This should succeed despite token returning false
        token.rescueAnyBEP20Tokens(address(maliciousToken), receiver, 100);
        
        console.log("--- AFTER-Trigger Rescue ---");
        uint256 afterBalance = maliciousToken.balanceOf(receiver);
        console.log("Receiver malicious token balance (AFTER):", afterBalance);
        
        // Compare balances and output vulnerability status
        bool balanceUnchanged = (beforeBalance == afterBalance);
        bool vulnerable = balanceUnchanged; // Balance remains unchanged -> vulnerability exists
        
        if (vulnerable) {
            console.log("Vulnerability Exists: rescueAnyBEP20Tokens did not revert and balance unchanged indicates silent failure");
        } else {
            console.log("Vulnerability not Exist: rescueAnyBEP20Tokens properly handled failed transfer");
        }
    }
}

// Mocks for router setup
contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xC0FFEE);
    }
}

contract MockWETH {
    // Dummy contract
}