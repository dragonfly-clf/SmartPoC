// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x39cfd754c85023648bf003bea2dd498c5612abfa.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    address owner = address(0x1);
    address user = address(0x2);
    address maliciousContract = address(new MaliciousContract());

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        vm.deal(owner, 10 ether);
        tokenBank.Deposit{value: 5 ether}();
        vm.stopPrank();
    }

    function testUncheckedWithdrawToHolder() public {
        console.log("=== Testing WithdrawToHolder ===");
        console.log("--- BEFORE-Trigger Withdraw ---");
        uint256 ownerHolderBefore = tokenBank.Holders(owner);
        uint256 maliciousBalBefore = maliciousContract.balance;
        console.log("Owner holder balance:", ownerHolderBefore);
        console.log("Malicious address ETH:", maliciousBalBefore);

        console.log("--- Trigger WithdrawToHolder (ETH) ---");
        vm.prank(owner);
        tokenBank.WithdrawToHolder(maliciousContract, 1 ether);

        console.log("--- AFTER-Trigger Withdraw ---");
        uint256 ownerHolderAfter = tokenBank.Holders(owner);
        uint256 maliciousBalAfter = maliciousContract.balance;
        console.log("Owner holder balance:", ownerHolderAfter);
        console.log("Malicious address ETH:", maliciousBalAfter);

        bool stateChanged = ownerHolderAfter < ownerHolderBefore;
        if (stateChanged && maliciousBalAfter == 0) {
            console.log("Vulnerability Exists: State changed despite failed ETH transfer");
        } else {
            console.log("Vulnerability not Exist: No state change detected");
        }
    }

    function testUncheckedWithdrawToken() public {
        MockToken mockToken = new MockToken();
        mockToken.mint(address(tokenBank), 1000);

        console.log("\n=== Testing WithdrawToken ===");
        console.log("--- BEFORE-Trigger WithdrawToken ---");
        uint256 bankBalanceBefore = mockToken.balanceOf(address(tokenBank));
        uint256 userBalanceBefore = mockToken.balanceOf(user);
        console.log("Bank token balance:", bankBalanceBefore);
        console.log("User token balance:", userBalanceBefore);

        console.log("--- Trigger WithdrawToken (ERC20) ---");
        bool success;
        bytes memory result;
        
        (success, result) = address(tokenBank).call(
            abi.encodeCall(tokenBank.WithdrawToken, (address(mockToken), 100, user))
        );

        console.log("--- AFTER-Trigger WithdrawToken ---");
        uint256 bankBalanceAfter = mockToken.balanceOf(address(tokenBank));
        uint256 userBalanceAfter = mockToken.balanceOf(user);
        console.log("Bank token balance:", bankBalanceAfter);
        console.log("User token balance:", userBalanceAfter);

        if (success) {
            bool balancesUnchanged = (bankBalanceAfter == bankBalanceBefore) &&
                                    (userBalanceAfter == userBalanceBefore);
            if (balancesUnchanged) {
                console.log("Vulnerability Exists: Transaction succeeded without token transfer");
            } else {
                console.log("Vulnerability not Exist: Token transfer succeeded");
            }
        } else {
            console.log("Vulnerability not Exist: Transaction reverted");
        }
    }

    function testUncheckedWitdrawTokenToHolder() public {
        MockToken mockToken = new MockToken();
        mockToken.mint(address(tokenBank), 1000);

        console.log("\n=== Testing WitdrawTokenToHolder ===");
        console.log("--- BEFORE-Trigger WitdrawTokenToHolder ---");
        uint256 bankBalanceBefore = mockToken.balanceOf(address(tokenBank));
        uint256 userBalanceBefore = mockToken.balanceOf(user);
        console.log("Bank token balance:", bankBalanceBefore);
        console.log("User token balance:", userBalanceBefore);

        console.log("--- Trigger WitdrawTokenToHolder ---");
        bool success;
        bytes memory result;
        
        (success, result) = address(tokenBank).call(
            abi.encodeCall(tokenBank.WitdrawTokenToHolder, (user, address(mockToken), 100))
        );

        console.log("--- AFTER-Trigger WitdrawTokenToHolder ---");
        uint256 bankBalanceAfter = mockToken.balanceOf(address(tokenBank));
        uint256 userBalanceAfter = mockToken.balanceOf(user);
        console.log("Bank token balance:", bankBalanceAfter);
        console.log("User token balance:", userBalanceAfter);

        if (success) {
            bool balancesUnchanged = (bankBalanceAfter == bankBalanceBefore) &&
                                    (userBalanceAfter == userBalanceBefore);
            if (balancesUnchanged) {
                console.log("Vulnerability Exists: Transaction succeeded without token transfer");
            } else {
                console.log("Vulnerability not Exist: Token transfer succeeded");
            }
        } else {
            console.log("Vulnerability not Exist: Transaction reverted");
        }
    }
}

contract MaliciousContract {
    // No payable fallback function - will reject ether transfers
}

contract MockToken {
    mapping (address => uint256) public balanceOf;
    
    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }
    
    function transfer(address, uint256) external pure returns (bool) {
        return false; // Always fail transfers
    }
}