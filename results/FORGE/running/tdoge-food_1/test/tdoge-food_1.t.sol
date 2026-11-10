// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TFOOD.sol";

contract TFOODHighFeeTest is Test {
    TFOOD token;
    address user1 = address(0x1);
    address fakePair = address(0x123);
    
    // Fixed addresses from TFOOD's constructor
    address constant receiveAddress = address(0xeAC7843FC2F24ace74f7BbA228F657D0f001bE16);
    address constant fundAddress = address(0x27f5108828d66B3df802eDF021633EBb8C8d106a);
    address constant buybackAddress = address(0xA8aDDC33EBa16fc7150649521eDEf5fc33f2d0de);
    address constant routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant fistAddress = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    // Mock contracts for external dependencies
    contract MinimalFIST {
        function approve(address, uint256) public pure returns (bool) {
            return true;
        }
    }
    
    contract MockRouter {
        function factory() public pure returns (address) {
            return address(0x1234);
        }
        
        function WETH() public pure returns (address) {
            return address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
        }
    }
    
    contract MockFactory {
        function createPair(address, address) public pure returns (address) {
            return address(0x123);
        }
    }

    function setUp() public {
        // Deploy mock contracts
        MinimalFIST fistMock = new MinimalFIST();
        MockRouter routerMock = new MockRouter();
        MockFactory factoryMock = new MockFactory();

        // Mock external contracts at fixed addresses
        vm.etch(fistAddress, address(fistMock).code);
        vm.etch(routerAddress, address(routerMock).code);
        vm.etch(address(0x1234), address(factoryMock).code);

        // Deploy token contract
        token = new TFOOD();
        
        // Fund initial tokens to test user
        uint256 decimals = token.decimals();
        uint256 amount = 1000 * 10 ** decimals;
        vm.prank(receiveAddress);
        token.transfer(user1, amount);
        
        // Configure token settings
        token.setSwapPairList(fakePair, true);
        token.setFundAddress(address(this));
    }

    function testHighFeeVulnerability() public {
        // Configure high-fee conditions
        token.setkb(2);
        token.goMoon();
        vm.roll(block.number + 1);

        uint256 amount = 100 * 10 ** token.decimals();
        uint256 expectedFee = amount * 90 / 100;
        uint256 expectedTransfer = amount - expectedFee;

        // Pre-transfer state
        console2.log("--- BEFORE Trigger ---");
        uint256 user1Before = token.balanceOf(user1);
        uint256 pairBefore = token.balanceOf(fakePair);
        uint256 fundBefore = token.balanceOf(address(this));
        console2.log("User1 balance: %s", user1Before);
        console2.log("FakePair balance: %s", pairBefore);
        console2.log("Fund balance: %s", fundBefore);

        // Trigger vulnerable transfer
        console2.log("--- Trigger: transfer(%s tokens) ---", amount);
        vm.prank(user1);
        token.transfer(fakePair, amount);
        
        // Post-transfer state
        console2.log("--- AFTER Trigger ---");
        uint256 user1After = token.balanceOf(user1);
        uint256 pairAfter = token.balanceOf(fakePair);
        uint256 fundAfter = token.balanceOf(address(this));
        console2.log("User1 balance: %s", user1After);
        console2.log("FakePair balance: %s", pairAfter);
        console2.log("Fund balance: %s", fundAfter);

        // Differential analysis
        console2.log("--- Differential Analysis ---");
        uint256 fundDelta = fundAfter - fundBefore;
        uint256 pairDelta = pairAfter - pairBefore;
        uint256 user1Delta = user1Before - user1After;
        console2.log("Fund increase: %s (expected: %s)", fundDelta, expectedFee);
        console2.log("Pair increase: %s (expected: %s)", pairDelta, expectedTransfer);
        console2.log("User1 decrease: %s (expected: %s)", user1Delta, amount);

        // Vulnerability verdict
        if(fundDelta == expectedFee && pairDelta == expectedTransfer && user1Delta == amount) {
            console2.log("Vulnerability Exists: Successfully collected 90% fee");
        } else {
            console2.log("Vulnerability not Exist: Unexpected fee behavior");
        }
    }
}