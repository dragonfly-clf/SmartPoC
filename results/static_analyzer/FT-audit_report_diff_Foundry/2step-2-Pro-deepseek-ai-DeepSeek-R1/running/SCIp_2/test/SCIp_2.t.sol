// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCIp.sol";

// Mock flash borrower contract to test flash loan function
contract NormalBorrower is IERC3156FlashBorrower {
    SCIp token;
    address owner;
    uint256 public lastFee;

    constructor(SCIp _token) {
        token = _token;
        owner = msg.sender;
    }

    function onFlashLoan(
        address,
        address,
        uint256 amount,
        uint256 fee,
        bytes calldata
    ) external override returns (bytes32) {
        lastFee = fee;
        // Approve token contract to spend the repayment amount
        token.approve(address(token), amount + fee);
        // Return the required hash to pass validation
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    // Helper function to initiate flash loan
    function startFlashLoan(uint256 amount) external {
        token.flashLoan(IERC3156FlashBorrower(address(this)), address(token), amount, "");
    }
}

contract SCIpFlashLoanTest is Test {
    SCIp public token;
    NormalBorrower public borrower;
    address public owner = address(1);

    function setUp() public {
        vm.startPrank(owner);
        token = new SCIp();
        borrower = new NormalBorrower(token);
        vm.stopPrank();
    }

    function test_FlashLoanFeeManipulation() public {
        vm.startPrank(owner);
        
        console2.log("--- BEFORE-Trigger ---");
        // Get initial states
        uint256 initialSupply = token.totalSupply();
        uint256 initialFee = borrower.lastFee();
        console2.log("Initial total supply: ", initialSupply);
        console2.log("Initial flash loan fee: ", initialFee);
        
        console2.log("--- Trigger Flash Loan ---");
        // Calculate and execute flash loan during trigger
        uint256 amount = 1000 * 10 ** token.decimals();
        borrower.startFlashLoan(amount);
        
        console2.log("--- AFTER-Trigger ---");
        // Check states after flash loan
        uint256 newSupply = token.totalSupply();
        uint256 fee = borrower.lastFee();
        console2.log("New total supply: ", newSupply);
        console2.log("Actual flash loan fee: ", fee);
        
        // Run differential checks
        console2.log("\n--- DIFFERENTIAL VERIFICATION ---");
        bool totalSupplyChanged = initialSupply != newSupply;
        bool feeNotZero = fee != 0;
        bool vulDetected = totalSupplyChanged || feeNotZero;
        
        console2.log("Total supply unchanged: ", !totalSupplyChanged ? "YES" : "NO");
        console2.log("Fee remains zero: ", !feeNotZero ? "YES" : "NO");
        console2.log("Vulnerability detected: ", vulDetected ? "YES" : "NO");
        
        // Final verdict
        if (vulDetected) {
            console2.log("Vulnerability Exists: Unexpected flash loan fee or total supply change detected");
        } else {
            console2.log("Vulnerability not Exist: Flash loan fee remains 0 and total supply unchanged");
        }

        // Maintain original test assertions
        assertEq(fee, 0, "Default fee should be 0");
        assertEq(initialSupply, newSupply, "Total supply should remain unchanged after flash loan");
    }
}