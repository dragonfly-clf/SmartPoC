// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract BadToken {
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract RevertingReceiver {
    fallback() external payable {
        revert();
    }

    receive() external payable {
        revert();
    }
}

contract TokenBankTest is Test {
    TokenBank tokenBank;
    BadToken badToken;
    RevertingReceiver revertingReceiver;
    address deployer = makeAddr("deployer");
    address depositor = makeAddr("depositor");
    uint256 constant DEPOSIT_AMOUNT = 1 ether;

    function setUp() public {
        vm.startPrank(deployer);
        tokenBank = new TokenBank();
        badToken = new BadToken();
        revertingReceiver = new RevertingReceiver();
        vm.stopPrank();
    }

    function test_tokenTransferFailure() public {
        vm.deal(depositor, DEPOSIT_AMOUNT);
        vm.prank(depositor);
        tokenBank.Deposit{value: DEPOSIT_AMOUNT}();

        console.log("--- BEFORE-Trigger State (tokenTransferFailure) ---");
        uint256 holdersDepositorBefore = tokenBank.Holders(depositor);
        uint256 bankEthBefore = address(tokenBank).balance;
        uint256 minDepositBefore = tokenBank.MinDeposit();
        console.log("Holders[depositor] before:", holdersDepositorBefore);
        console.log("Contract ETH before:", bankEthBefore);
        console.log("MinDeposit before:", minDepositBefore);

        console.log("--- Trigger: WitdrawTokenToHolder ---");
        vm.prank(deployer);
        tokenBank.WitdrawTokenToHolder(depositor, address(badToken), 0);

        console.log("--- AFTER-Trigger State (tokenTransferFailure) ---");
        uint256 holdersDepositorAfter = tokenBank.Holders(depositor);
        uint256 bankEthAfter = address(tokenBank).balance;
        uint256 minDepositAfter = tokenBank.MinDeposit();
        console.log("Holders[depositor] after:", holdersDepositorAfter);
        console.log("Contract ETH after:", bankEthAfter);
        console.log("MinDeposit after:", minDepositAfter);

        console.log("--- State Change Comparison ---");
        bool holderChanged = holdersDepositorAfter != holdersDepositorBefore;
        bool ethChanged = bankEthAfter != bankEthBefore;
        bool minDepChanged = minDepositAfter != minDepositBefore;
        bool stateChanged = holderChanged || ethChanged || minDepChanged;
        
        console.log("Holders changed:", holderChanged);
        console.log("ETH balance changed:", ethChanged);
        console.log("MinDeposit changed:", minDepChanged);
        
        if (stateChanged) {
            console.log("Vulnerability Exists: State modified despite failed token transfer");
        } else {
            console.log("Vulnerability not Exist: No state modifications occurred");
        }
    }

    function test_etherTransferFailure() public {
        vm.deal(address(revertingReceiver), DEPOSIT_AMOUNT);
        vm.prank(address(revertingReceiver));
        tokenBank.Deposit{value: DEPOSIT_AMOUNT}();

        console.log("--- BEFORE-Trigger State (etherTransferFailure) ---");
        uint256 holdersRevertingBefore = tokenBank.Holders(address(revertingReceiver));
        uint256 bankEthBefore = address(tokenBank).balance;
        uint256 minDepositBefore = tokenBank.MinDeposit();
        console.log("Holders[revertingReceiver] before:", holdersRevertingBefore);
        console.log("Contract ETH before:", bankEthBefore);
        console.log("MinDeposit before:", minDepositBefore);

        console.log("--- Trigger: WithdrawToHolder ---");
        vm.prank(deployer);
        tokenBank.WithdrawToHolder(address(revertingReceiver), 1);

        console.log("--- AFTER-Trigger State (etherTransferFailure) ---");
        uint256 holdersRevertingAfter = tokenBank.Holders(address(revertingReceiver));
        uint256 bankEthAfter = address(tokenBank).balance;
        uint256 minDepositAfter = tokenBank.MinDeposit();
        console.log("Holders[revertingReceiver] after:", holdersRevertingAfter);
        console.log("Contract ETH after:", bankEthAfter);
        console.log("MinDeposit after:", minDepositAfter);

        console.log("--- State Change Comparison ---");
        bool holderChanged = holdersRevertingAfter != holdersRevertingBefore;
        bool ethChanged = bankEthAfter != bankEthBefore;
        bool minDepChanged = minDepositAfter != minDepositBefore;
        bool stateChanged = holderChanged || ethChanged || minDepChanged;
        
        console.log("Holders changed:", holderChanged);
        console.log("ETH balance changed:", ethChanged);
        console.log("MinDeposit changed:", minDepChanged);
        
        if (stateChanged) {
            console.log("Vulnerability Exists: State modified despite failed ETH transfer");
        } else {
            console.log("Vulnerability not Exist: No state modifications occurred");
        }

        assertEq(
            address(tokenBank).balance, 
            bankEthBefore,
            "ETH not deducted despite failed transfer"
        );
    }
}