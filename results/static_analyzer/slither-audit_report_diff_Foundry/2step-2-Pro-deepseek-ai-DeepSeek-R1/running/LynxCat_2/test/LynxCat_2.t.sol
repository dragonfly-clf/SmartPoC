// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LynxCat.sol";

contract MaliciousToken {
    mapping(address => uint256) public balanceOf;
    
    function transfer(address, uint256) external pure returns (bool) {
        return false; // Always returns false
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] = amount;
    }
}

contract LynxCatTest is Test {
    LynxCat public lynxCat;
    MaliciousToken public maliciousToken;

    address owner = makeAddr("owner");
    address recipient = makeAddr("recipient");
    uint256 constant AMOUNT = 100 ether;

    // Mock addresses for Uniswap dependencies
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_WETH = address(0x111);
    address constant MOCK_FACTORY = address(0x222);
    address constant MOCK_PAIR = address(0x333);

    function setUp() public {
        vm.startPrank(owner);

        // Mock Uniswap router calls
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock factory's createPair
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        // Deploy LynxCat contract
        lynxCat = new LynxCat();
        
        // Deploy malicious token and fund LynxCat
        maliciousToken = new MaliciousToken();
        maliciousToken.mint(address(lynxCat), AMOUNT);
        
        vm.stopPrank();
    }

    function test_withdrawForeignTokenIgnoresReturnValue() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Caller: owner, Recipient: %s, Token: %s", recipient, address(maliciousToken));

        console.log("--- Trigger withdrawForeignToken ---");
        vm.prank(owner);
        lynxCat.withdrawForeignToken(
            address(maliciousToken), 
            recipient, 
            AMOUNT
        );
        
        console.log("--- AFTER-Trigger ---");
        console.log("Function completed execution without revert");
        console.log("Vulnerability Exists: Function ignores false return value from token transfer");
    }
}