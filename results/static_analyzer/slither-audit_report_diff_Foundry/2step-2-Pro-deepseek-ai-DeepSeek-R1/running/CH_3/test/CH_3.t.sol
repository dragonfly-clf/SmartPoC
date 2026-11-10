// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CH.sol";

contract MockBUSD {
    function approve(address, uint256) external pure returns (bool) {
        return true;
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract BadToken {
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract ClaimTokenTest is Test {
    CH public token;

    address busdAddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address factoryAddress = 0x1111111111111111111111111111111111111111;
    address pairAddress = 0x2222222222222222222222222222222222222222;

    function setUp() public {
        MockBUSD mockBUSD = new MockBUSD();
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        vm.etch(busdAddress, address(mockBUSD).code);
        vm.etch(routerAddress, address(mockRouter).code);
        vm.etch(factoryAddress, address(mockFactory).code);

        token = new CH();
        token.setFundAddress(address(this));
    }

    function testClaimTokenIgnoreFailedTransfer() public {
        BadToken badToken = new BadToken();
        address recipient = makeAddr("recipient");
        
        console.log("--- BEFORE-Trigger ---");
        console.log("Pre-state: No state variables to check");
        console.log("Expecting failed transfer call to badToken without revert");
        
        console.log("--- Trigger ClaimToken ---");
        vm.expectCall(
            address(badToken), 
            abi.encodeCall(BadToken.transfer, (recipient, 1 ether))
        );
        token.claimToken(address(badToken), 1 ether, recipient);
        
        console.log("--- AFTER-Trigger ---");
        console.log("Post-state: No state changes occurred");
        console.log("Observed expected call without revert");
        console.log("Vulnerability Exists: Failed token transfer didn't revert as required");
    }
}