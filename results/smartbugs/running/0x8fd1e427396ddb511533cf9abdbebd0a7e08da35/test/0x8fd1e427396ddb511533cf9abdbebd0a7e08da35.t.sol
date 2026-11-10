// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    address owner = address(0x1);
    address user = address(0x2);
    address attacker = address(0x3);
    
    MockToken failingToken;

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        failingToken = new MockToken();
        vm.stopPrank();

        vm.deal(owner, 10 ether);
        vm.deal(address(tokenBank), 10 ether);
        
        // Fund TokenBank with MockTokens for token tests
        vm.prank(owner);
        failingToken.transfer(address(tokenBank), 100 ether);
    }

    function testUncheckedWithdrawToHolder() public {
        console2.log("--- BEFORE-Trigger State ---");
        uint256 tokenBankBalanceBefore = address(tokenBank).balance;
        uint256 holderBalanceBefore = tokenBank.Holders(owner);
        address nonPayableContract = address(new NonPayableContract());
        console2.log("TokenBank ETH:", tokenBankBalanceBefore);
        console2.log("Owner's Holder Balance:", holderBalanceBefore);

        // Simulate deposit to set owner as holder
        vm.prank(owner);
        tokenBank.Deposit{value: 1 ether}();
        tokenBankBalanceBefore = address(tokenBank).balance;
        holderBalanceBefore = tokenBank.Holders(owner);

        console2.log("--- Trigger WithdrawToHolder (Removes 1 ETH) ---");
        vm.prank(owner);
        tokenBank.WithdrawToHolder(nonPayableContract, 1 ether);

        console2.log("--- AFTER-Trigger State ---");
        uint256 tokenBankBalanceAfter = address(tokenBank).balance;
        uint256 holderBalanceAfter = tokenBank.Holders(owner);
        console2.log("TokenBank ETH:", tokenBankBalanceAfter);
        console2.log("Owner's Holder Balance:", holderBalanceAfter);

        // Vulnerability verification: Holder balance decreased without ETH transfer
        bool holderBalanceDecreased = holderBalanceAfter < holderBalanceBefore;
        bool ethNotTransferred = (nonPayableContract.balance == 0) && 
                               (tokenBankBalanceBefore == tokenBankBalanceAfter);

        console2.log("Holder balance reduced without ETH transfer:",
            (holderBalanceDecreased && ethNotTransferred) ? "YES" : "NO");

        if (holderBalanceDecreased && ethNotTransferred) {
            console2.log("Vulnerability Exists: ETH withdrawal balance updated but ETH not transferred");
        } else {
            console2.log("Vulnerability not Exist: ETH withdrawal behaves correctly");
        }
    }

    function testUncheckedWithdrawToken() public {
        failingToken.setShouldFail(true);
        console2.log("--- BEFORE-Trigger State ---");
        uint256 bankTokenBalanceBefore = failingToken.balanceOf(address(tokenBank));
        uint256 userTokenBalanceBefore = failingToken.balanceOf(user);
        console2.log("TokenBank token balance:", bankTokenBalanceBefore);
        console2.log("User token balance:", userTokenBalanceBefore);

        console2.log("--- Trigger WithdrawToken (Should transfer 100 tokens) ---");
        vm.prank(owner);
        tokenBank.WithdrawToken(address(failingToken), 100 ether, user);

        console2.log("--- AFTER-Trigger State ---");
        uint256 bankTokenBalanceAfter = failingToken.balanceOf(address(tokenBank));
        uint256 userTokenBalanceAfter = failingToken.balanceOf(user);
        console2.log("TokenBank token balance:", bankTokenBalanceAfter);
        console2.log("User token balance:", userTokenBalanceAfter);

        // Vulnerability verification: Balances unchanged after failed transfer
        bool balancesUnchanged = (bankTokenBalanceBefore == bankTokenBalanceAfter) && 
                                (userTokenBalanceBefore == userTokenBalanceAfter);
        
        console2.log("Token transfer failed without state rollback:",
            balancesUnchanged ? "YES" : "NO");
        
        if (balancesUnchanged) {
            console2.log("Vulnerability Exists: Token balance update occurred even when token transfer failed");
        } else {
            console2.log("Vulnerability not Exist: Token transfer behaves correctly");
        }
    }

    function testUncheckedWitdrawTokenToHolder() public {
        failingToken.setShouldFail(true);
        vm.prank(owner);
        tokenBank.Deposit{value: 1 ether}();  // Owner becomes holder
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 bankTokenBalanceBefore = failingToken.balanceOf(address(tokenBank));
        uint256 recipientTokenBalanceBefore = failingToken.balanceOf(user);
        console2.log("TokenBank token balance:", bankTokenBalanceBefore);
        console2.log("Recipient token balance:", recipientTokenBalanceBefore);

        console2.log("--- Trigger WitdrawTokenToHolder (100 tokens) ---");
        vm.prank(owner);
        tokenBank.WitdrawTokenToHolder(user, address(failingToken), 100 ether);

        console2.log("--- AFTER-Trigger State ---");
        uint256 bankTokenBalanceAfter = failingToken.balanceOf(address(tokenBank));
        uint256 recipientTokenBalanceAfter = failingToken.balanceOf(user);
        console2.log("TokenBank token balance:", bankTokenBalanceAfter);
        console2.log("Recipient token balance:", recipientTokenBalanceAfter);

        // Vulnerability verification
        bool balancesUnchanged = (bankTokenBalanceBefore == bankTokenBalanceAfter) && 
                                (recipientTokenBalanceBefore == recipientTokenBalanceAfter);
        
        console2.log("Token transfer failed without state rollback:",
            balancesUnchanged ? "YES" : "NO");
        
        if (balancesUnchanged) {
            console2.log("Vulnerability Exists: TokenHolder balance update occurred even when token transfer failed");
        } else {
            console2.log("Vulnerability not Exist: TokenHolder transfer behaves correctly");
        }
    }
}

contract NonPayableContract {
    // No payable fallback function
}

contract MockToken {
    mapping(address => uint256) public _balances;
    bool public shouldFail;

    constructor() {
        _balances[msg.sender] = 10000 ether;
    }

    function mint(address to, uint256 amount) public {
        _balances[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        if (shouldFail) {
            return false;
        }
        require(_balances[msg.sender] >= amount, "Insufficient balance");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        return true;
    }

    function setShouldFail(bool _shouldFail) public {
        shouldFail = _shouldFail;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
}