// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BabyDogeCoin20.sol";

// Mock Uniswap contracts to avoid external dependencies
contract MockUniswapV2Factory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address)
        external
        view
        returns (address)
    {
        return pair;
    }
}

contract MockUniswapV2Router {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory) {
        factory = _factory;
        WETH = address(0x1);
    }
}

contract BabyDogeCoin20ExcessiveFeeTest is Test {
    BabyDogeCoin20 token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    address marketingWallet = address(0x4);
    
    // Mock addresses
    address mockPair;
    address testRouter;

    function setUp() public {
        // Fund test contract
        vm.deal(address(this), 1 ether);
        
        // Setup Uniswap mocks
        mockPair = address(0x9);
        address mockFactory = address(
            new MockUniswapV2Factory(mockPair)
        );
        testRouter = address(new MockUniswapV2Router(mockFactory));
        
        // Create deployment parameters
        BabyDogeCoin20.Parameters memory params = BabyDogeCoin20.Parameters({
            marketingWallet: marketingWallet,
            centiBuyTax: 500,  // 5%
            centiSellTax: 500, // 5%
            maxTxPercent: 100,  // 1% of total supply
            maxWalletPercent: 100 // 1% of total supply
        });

        // Deploy token with 0.1 ether funds
        token = new BabyDogeCoin20{value: 0.1 ether}(
            "HighTaxTest",
            "TAXT",
            1_000_000 * 10**18, // Total supply
            18,                 // Decimals
            params,
            testRouter,         // Mock router
            marketingWallet     // Receives 0.1 ether
        );

        // Configure fee exclusion
        token.excludeFromFees(owner, true);
        token.transfer(user1, 100 * 10**18);
    }

    function testSetExcessiveBuyTax() public {
        // Pre-trigger state capture
        console2.log("--- BEFORE Trigger ---");
        uint256 preTax = token.centiBuyTax();
        console2.log("Pre-trigger buy tax (centipercent):", preTax);
        uint256 preContractTokenBalance = token.balanceOf(address(token));
        console2.log("Pre-trigger contract token balance:", preContractTokenBalance);
        uint256 preUser1Balance = token.balanceOf(user1);
        console2.log("Pre-trigger user1 balance:", preUser1Balance);
        uint256 preUser2Balance = token.balanceOf(user2);
        console2.log("Pre-trigger user2 balance:", preUser2Balance);

        console2.log("--- Trigger: setBuyTax(26, 0, 0) ---");
        // Set excessively high buy tax (26%)
        token.setBuyTax(26, 0, 0);
        
        // Post-trigger state capture
        console2.log("--- AFTER Trigger ---");
        uint256 postTax = token.centiBuyTax();
        console2.log("Post-trigger buy tax (centipercent):", postTax);
        uint256 postContractTokenBalance = token.balanceOf(address(token));
        console2.log("Post-trigger contract token balance:", postContractTokenBalance);
        
        // Differential comparison - Tax rate changed
        bool taxChanged = (preTax != postTax);
        console2.log("Tax rate changed:", taxChanged ? "YES, ALTERED" : "NO, UNCHANGED");
        
        // Execute the transfer to observe fee effects
        uint256 transferAmount = 10 * 10**18;
        uint256 expectedFee = (transferAmount * postTax) / 10000;
        
        // Additional pre-transfer balance snapshot for fee effect comparison
        console2.log("--- BEFORE Transfer ---");
        uint256 preTxContractBalance = token.balanceOf(address(token));
        console2.log("Pre-transfer contract balance:", preTxContractBalance);
        uint256 preTxUser1Balance = token.balanceOf(user1);
        console2.log("Pre-transfer user1 balance:", preTxUser1Balance);
        uint256 preTxUser2Balance = token.balanceOf(user2);
        console2.log("Pre-transfer user2 balance:", preTxUser2Balance);
        
        vm.prank(user1);
        token.transfer(user2, transferAmount);
        
        // Post-transfer state capture
        console2.log("--- AFTER Transfer ---");
        uint256 postTxContractBalance = token.balanceOf(address(token));
        console2.log("Post-transfer contract balance:", postTxContractBalance);
        uint256 postTxUser1Balance = token.balanceOf(user1);
        console2.log("Post-transfer user1 balance:", postTxUser1Balance);
        uint256 postTxUser2Balance = token.balanceOf(user2);
        console2.log("Post-transfer user2 balance:", postTxUser2Balance);
        
        // Differential comparison - Contract balance increased by expected fee
        uint256 contractBalanceIncrease = postTxContractBalance - preTxContractBalance;
        console2.log("Contract balance increase:", contractBalanceIncrease);
        console2.log("Expected fee amount:", expectedFee);
        bool feeAppliedCorrectly = (contractBalanceIncrease == expectedFee);

        // Vulnerability verdict - Verbose state comparison
        bool vulnerabilityExists = taxChanged && (postTax == 2600) && feeAppliedCorrectly;
        
        if (vulnerabilityExists) {
            console2.log("Vulnerability EXISTS: Tax rate successfully changed to 26.00% and fee applied correctly");
        } else {
            console2.log("Vulnerability NOT EXIST: Tax change failed or incorrect fee application");
        }
        
        // Final verdict (required format)
        if(vulnerabilityExists) {
            console2.log("Vulnerability Exists: Owner can manipulate tax beyond intended limits");
        } else {
            console2.log("Vulnerability not Exist: Tax manipulation unsuccessful or fee application incorrect");
        }
    }
}