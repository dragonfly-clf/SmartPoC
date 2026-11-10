// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCIp.sol";

contract MockBorrower is IERC3156FlashBorrower {
    function onFlashLoan(
        address,        // initiator
        address,        // token
        uint256,        // amount
        uint256,        // fee
        bytes calldata  // data
    ) external pure returns (bytes32) {
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}

contract FlashFeeReceiverToken is SCIp {
    address private feeReceiver;

    constructor() SCIp() {
        feeReceiver = address(0x1);
    }

    function _flashFeeReceiver() internal view override returns (address) {
        return feeReceiver;
    }

    function _flashFee(address, uint256 amount) internal view override returns (uint256) {
        return amount / 100; // 1% fee
    }
}

contract FlashLoanFeeTest is Test {
    FlashFeeReceiverToken token;
    MockBorrower borrower;
    address constant FEE_RECEIVER = address(0x1);
    uint256 constant LOAN_AMOUNT = 1000e9;

    function setUp() public {
        token = new FlashFeeReceiverToken();
        borrower = new MockBorrower();
        
        // Fund borrower to cover fees
        token.transfer(address(borrower), LOAN_AMOUNT / 100);
        
        // Borrower approves token contract for repayment
        vm.prank(address(borrower));
        token.approve(address(token), type(uint256).max);
    }

    function test_FlashLoanFeeAccounting() public {
        uint256 fee = token.flashFee(address(token), LOAN_AMOUNT);
        require(fee > 0, "Fee must be non-zero");
        
        console.log("--- BEFORE-Trigger Fee State ---");
        uint256 preFeeReceiverBalance = token.balanceOf(FEE_RECEIVER);
        uint256 preBorrowerBalance = token.balanceOf(address(borrower));
        uint256 preTotalSupply = token.totalSupply();
        
        console.log("Fee Receiver Balance: %s", preFeeReceiverBalance);
        console.log("Borrower Balance: %s", preBorrowerBalance);
        console.log("Total Supply: %s", preTotalSupply);
        console.log("Expected Fee: %s", fee);

        console.log("--- Trigger: flashLoan ---");
        token.flashLoan(borrower, address(token), LOAN_AMOUNT, "");

        console.log("--- AFTER-Trigger Fee State ---");
        uint256 postFeeReceiverBalance = token.balanceOf(FEE_RECEIVER);
        uint256 postBorrowerBalance = token.balanceOf(address(borrower));
        uint256 postTotalSupply = token.totalSupply();
        
        console.log("Fee Receiver Balance: %s", postFeeReceiverBalance);
        console.log("Borrower Balance: %s", postBorrowerBalance);
        console.log("Total Supply: %s", postTotalSupply);

        uint256 feeReceiverDiff = postFeeReceiverBalance - preFeeReceiverBalance;
        uint256 borrowerDiff = preBorrowerBalance - postBorrowerBalance;
        uint256 totalSupplyDiff = preTotalSupply - postTotalSupply;  // should be 0

        console.log("Fee Receiver Change: %s (expected %s)", feeReceiverDiff, fee);
        console.log("Borrower Change: %s (expected %s)", borrowerDiff, fee);
        console.log("Total Supply Change: %s (expected 0)", totalSupplyDiff);

        bool vulnerabilityExists = false;
        string memory reason = "";
        
        // Check fee transfer to receiver
        if (feeReceiverDiff != fee) {
            vulnerabilityExists = true;
            reason = "Fee not transferred to receiver correctly";
        }
        
        // Check fee deduction from borrower
        if (borrowerDiff != fee) {
            vulnerabilityExists = true;
            reason = "Borrower balance change does not match fee amount";
        }
        
        // Check supply remains constant
        if (postTotalSupply != preTotalSupply) {
            vulnerabilityExists = true;
            reason = "Total supply changed unexpectedly";
        }
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: %s", reason);
        } else {
            console.log("Vulnerability not Exist: Flash loan fee accounted correctly");
        }
    }
}