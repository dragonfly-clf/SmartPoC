// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract MaliciousToken {
    mapping(address => uint256) public balances;

    constructor() payable {}

    function mint(address to, uint256 amount) external {
        balances[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[to] += amount;
        return true;
    }
}

contract UnderflowTest is Test {
    TokenBank public tokenBank;
    MaliciousToken public token;
    address owner = address(0xABCD);
    address holder = address(0x1234);

    function setUp() public {
        vm.prank(owner);
        tokenBank = new TokenBank();

        token = new MaliciousToken();
        token.mint(address(tokenBank), 100); // TokenBank gets 100 tokens
        vm.deal(holder, 1 ether);

        vm.prank(holder);
        tokenBank.Deposit{value: 1 ether}();
    }

    function testTokenBankWithdrawalResetsHolderStateWithoutTransfer() public {
        // Token balances before transfer attempt
        uint256 tokenBankBalanceBefore = token.balances(address(tokenBank));
        uint256 holderBalanceBefore = token.balances(holder);

        console2.log("--- BEFORE-Trigger Holder State ---");
        uint256 holderDepositedBefore = tokenBank.Holders(holder);
        console2.log("Holder deposited amount (wei):", holderDepositedBefore);
        console2.log("Holder deposited amount (ether):", holderDepositedBefore / 1e18);
        console2.log("Initial deposit status:", holderDepositedBefore > 0 ? "Active" : "Inactive");

        console2.log("--- Trigger Withdrawal with Invalid Amount ---");
        vm.prank(owner);
        tokenBank.WitdrawTokenToHolder(holder, address(token), 101);

        console2.log("--- AFTER-Trigger Holder State ---");
        uint256 holderDepositedAfter = tokenBank.Holders(holder);
        console2.log("Holder deposited amount (wei):", holderDepositedAfter);
        console2.log("Holder deposited amount (ether):", holderDepositedAfter / 1e18);
        console2.log("Final deposit status:", holderDepositedAfter > 0 ? "Active" : "Inactive");

        bool stateReset = holderDepositedAfter == 0;
        bool initialDepositExists = holderDepositedBefore == 1 ether;
        bool vulnerabilityExists = initialDepositExists && stateReset;

        console2.log("State changed to zero:", stateReset ? "YES" : "NO");
        console2.log("Vulnerability verified:", vulnerabilityExists ? "YES" : "NO");

        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Holder state incorrectly reset after failed token transfer");
        } else {
            console2.log("Vulnerability not Exist: Holder state remains unchanged");
        }

        // Original balance checks
        uint256 tokenBankBalanceAfter = token.balances(address(tokenBank));
        uint256 holderBalanceAfter = token.balances(holder);
        assertEq(tokenBankBalanceAfter, tokenBankBalanceBefore);
        assertEq(holderBalanceAfter, holderBalanceBefore);

        // Verify subsequent withdrawal
        vm.prank(owner);
        tokenBank.WitdrawTokenToHolder(holder, address(token), 0);

        // Manual token withdrawal verification
        vm.prank(owner);
        tokenBank.WithdrawToken(address(token), 100, address(this));
        assertEq(token.balances(address(tokenBank)), 0);
        assertEq(token.balances(address(this)), 100);
    }
}