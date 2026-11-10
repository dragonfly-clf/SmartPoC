// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ZAX.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address, uint256) external pure returns (bool) {
        return false; // Always returns false
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor() {
        factory = address(this);
        WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }

    function createPair(address, address) external pure returns (address) {
        return address(0xCAFE); // Changed to prevent deadWallet conflict
    }
}

contract ZAXRescueTokenTest is Test {
    ZAX zax;
    MockToken maliciousToken;
    address user = address(0xAA);
    uint256 amount = 1000 ether;

    function setUp() public {
        MockRouter router = new MockRouter();
        zax = new ZAX(address(router));
        maliciousToken = new MockToken();
        
        maliciousToken.mint(address(zax), amount);
    }

    function testRescueTokensIgnoresFailure() public {
        console.log("--- BEFORE-Trigger Rescue ---");
        uint256 initialZaxBalance = maliciousToken.balanceOf(address(zax));
        uint256 initialUserBalance = maliciousToken.balanceOf(user);
        console.log("ZAX contract balance (malicious token) before:", initialZaxBalance);
        console.log("User balance (malicious token) before:", initialUserBalance);

        console.log("--- Trigger Rescue ---");
        // Execute rescue function - should complete without reverting
        zax.rescueAnyBEP20Tokens(address(maliciousToken), user, amount);

        console.log("--- AFTER-Trigger Rescue ---");
        uint256 zaxBalanceAfter = maliciousToken.balanceOf(address(zax));
        uint256 userBalanceAfter = maliciousToken.balanceOf(user);
        console.log("ZAX contract balance (malicious token) after:", zaxBalanceAfter);
        console.log("User balance (malicious token) after:", userBalanceAfter);

        bool balancesUnchanged = (zaxBalanceAfter == initialZaxBalance) && 
                                 (userBalanceAfter == initialUserBalance);
    
        if (balancesUnchanged) {
            console.log("Vulnerability Exists: rescueAnyBEP20Tokens ignored transfer failure without state change");
            assertTrue(true); // Explicit pass for testing framework
        } else {
            console.log("Vulnerability not Exist: Balances were altered during failed transfer operation");
            fail("Vulnerability not Exist: State changed unexpectedly");
        }
    }
}