// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RD2E.sol";

contract RD2EPrivilegeTest is Test {
    RD2E public token;
    MockERC20 public mockToken;
    
    address owner = makeAddr("owner");
    uint256 initialERC20Balance = 1000 ether;
    uint256 withdrawAmount = 500 ether;

    function setUp() public {
        // Deploy contracts
        vm.startPrank(owner);
        token = new RD2E();
        mockToken = new MockERC20();
        vm.stopPrank();

        // Fund token contract with mock tokens
        mockToken.mint(address(token), initialERC20Balance);
        
        // Fund token contract with Ether
        vm.deal(address(token), 10 ether);
    }

    function testWithdrawStuckERC20() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialOwnerBalance = mockToken.balanceOf(owner);
        uint256 initialTokenBalance = mockToken.balanceOf(address(token));
        console.log("Owner token balance before: %s", initialOwnerBalance);
        console.log("Contract token balance before: %s", initialTokenBalance);

        console.log("--- Trigger Action: withdrawalStuck(address(mockToken), %s) ---", withdrawAmount);
        vm.prank(owner);
        token.withdrawalStuck(address(mockToken), withdrawAmount);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalOwnerBalance = mockToken.balanceOf(owner);
        uint256 finalTokenBalance = mockToken.balanceOf(address(token));
        console.log("Owner token balance after: %s", finalOwnerBalance);
        console.log("Contract token balance after: %s", finalTokenBalance);
        
        // Vulnerability verification
        bool fundsTransferred = (finalOwnerBalance == initialOwnerBalance + withdrawAmount) &&
                               (finalTokenBalance == initialTokenBalance - withdrawAmount);
        
        if (fundsTransferred) {
            console.log("Vulnerability Exists: Owner successfully withdrew stuck ERC20 tokens");
        } else {
            console.log("Vulnerability not Exist: Withdrawal did not modify balances as expected");
        }

        // Existing assertions
        assertEq(mockToken.balanceOf(owner), initialOwnerBalance + withdrawAmount);
        assertEq(mockToken.balanceOf(address(token)), initialTokenBalance - withdrawAmount);
    }

    function testWithdrawStuckETH() public {
        uint256 withdrawEth = 5 ether;
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialTokenBalance = address(token).balance;
        console.log("Owner ETH balance before: %s", initialOwnerBalance);
        console.log("Contract ETH balance before: %s", initialTokenBalance);

        console.log("--- Trigger Action: withdrawalStuck(address(0), %s) ---", withdrawEth);
        vm.prank(owner);
        token.withdrawalStuck(address(0), withdrawEth);
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalOwnerBalance = owner.balance;
        uint256 finalTokenBalance = address(token).balance;
        console.log("Owner ETH balance after: %s", finalOwnerBalance);
        console.log("Contract ETH balance after: %s", finalTokenBalance);
        
        // Vulnerability verification
        bool fundsTransferred = (finalOwnerBalance == initialOwnerBalance + withdrawEth) &&
                               (finalTokenBalance == initialTokenBalance - withdrawEth);
        
        if (fundsTransferred) {
            console.log("Vulnerability Exists: Owner successfully withdrew stuck ETH");
        } else {
            console.log("Vulnerability not Exist: ETH withdrawal did not modify balances as expected");
        }

        // Existing assertions
        assertEq(owner.balance, initialOwnerBalance + withdrawEth);
        assertEq(address(token).balance, initialTokenBalance - withdrawEth);
    }

    function testWithdrawMaxERC20() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialOwnerBalance = mockToken.balanceOf(owner);
        uint256 initialTokenBalance = mockToken.balanceOf(address(token));
        console.log("Owner token balance before: %s", initialOwnerBalance);
        console.log("Contract token balance before: %s", initialTokenBalance);

        console.log("--- Trigger Action: withdrawalStuckMax(address(mockToken)) ---");
        vm.prank(owner);
        token.withdrawalStuckMax(address(mockToken));
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalOwnerBalance = mockToken.balanceOf(owner);
        uint256 finalTokenBalance = mockToken.balanceOf(address(token));
        console.log("Owner token balance after: %s", finalOwnerBalance);
        console.log("Contract token balance after: %s", finalTokenBalance);
        
        // Vulnerability verification
        bool fundsDrained = (finalOwnerBalance == initialOwnerBalance + initialTokenBalance) &&
                            (finalTokenBalance == 0);
        
        if (fundsDrained) {
            console.log("Vulnerability Exists: Owner successfully drained all ERC20 tokens");
        } else {
            console.log("Vulnerability not Exist: Max withdrawal did not drain token balance");
        }

        // Existing assertions
        assertEq(mockToken.balanceOf(owner), initialOwnerBalance + initialTokenBalance);
        assertEq(mockToken.balanceOf(address(token)), 0);
    }

    function testWithdrawMaxETH() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialTokenBalance = address(token).balance;
        console.log("Owner ETH balance before: %s", initialOwnerBalance);
        console.log("Contract ETH balance before: %s", initialTokenBalance);

        console.log("--- Trigger Action: withdrawalStuckMax(address(0)) ---");
        vm.prank(owner);
        token.withdrawalStuckMax(address(0));
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalOwnerBalance = owner.balance;
        uint256 finalTokenBalance = address(token).balance;
        console.log("Owner ETH balance after: %s", finalOwnerBalance);
        console.log("Contract ETH balance after: %s", finalTokenBalance);
        
        // Vulnerability verification
        bool fundsDrained = (finalOwnerBalance == initialOwnerBalance + initialTokenBalance) &&
                            (finalTokenBalance == 0);
        
        if (fundsDrained) {
            console.log("Vulnerability Exists: Owner successfully drained all ETH");
        } else {
            console.log("Vulnerability not Exist: Max ETH withdrawal did not drain balance");
        }

        // Existing assertions
        assertEq(owner.balance, initialOwnerBalance + initialTokenBalance);
        assertEq(address(token).balance, 0);
    }
}

contract MockERC20 {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}