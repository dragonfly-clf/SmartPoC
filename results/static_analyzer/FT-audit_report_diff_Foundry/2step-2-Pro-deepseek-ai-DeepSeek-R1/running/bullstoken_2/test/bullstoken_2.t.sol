// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/bullstoken.sol";

contract BullCoinRoundingLossTest is Test {
    BullCoin token;
    
    // Wallet addresses for minting (using test addresses)
    address constant LP_WALLET = address(0xBEEF);
    address constant ECO_WALLET = address(0xCAFE);
    address constant AIRDROP_WALLET = address(0xF00D);
    
    // Total supply that may cause rounding issue
    uint256 constant TOTAL_SUPPLY = 999;

    function setUp() public {
        token = new BullCoin(
            TOTAL_SUPPLY,
            LP_WALLET,
            ECO_WALLET,
            AIRDROP_WALLET
        );
    }

    function testTokenDistributionRounding() public {
        // BEFORE: Compute expected distribution values
        emit log("--- BEFORE-Trigger Distribution ---");
        uint256 expectedTotal = TOTAL_SUPPLY * 1e18;
        uint256 expectedLP = (TOTAL_SUPPLY * 600 * 1e18) / 1000;
        uint256 expectedAirdrop = (TOTAL_SUPPLY * 350 * 1e18) / 1000;
        uint256 expectedEco = (TOTAL_SUPPLY * 50 * 1e18) / 1000;
        
        emit log_string("Expected LP");
        emit log_uint(expectedLP);
        emit log_string("Expected Airdrop");
        emit log_uint(expectedAirdrop);
        emit log_string("Expected Eco");
        emit log_uint(expectedEco);
        emit log_string("Expected Total Supply");
        emit log_uint(expectedTotal);

        // TRIGGER: Token distribution happens in constructor
        emit log("--- Trigger Constructor Distribution ---");

        // AFTER: Get actual distributed amounts
        emit log("--- AFTER-Trigger Distribution ---");
        uint256 actualLP = token.balanceOf(LP_WALLET);
        uint256 actualAirdrop = token.balanceOf(AIRDROP_WALLET);
        uint256 actualEco = token.balanceOf(ECO_WALLET);
        uint256 actualTotal = token.totalSupply();
        
        emit log_string("Actual LP");
        emit log_uint(actualLP);
        emit log_string("Actual Airdrop");
        emit log_uint(actualAirdrop);
        emit log_string("Actual Eco");
        emit log_uint(actualEco);
        emit log_string("Actual Total Supply");
        emit log_uint(actualTotal);

        // Differential comparison
        bool roundingDetected = (actualLP != expectedLP) || 
                                (actualAirdrop != expectedAirdrop) || 
                                (actualEco != expectedEco) || 
                                (actualTotal != expectedTotal);
        
        uint256 dustLoss = expectedTotal - actualTotal;
        if (dustLoss > 0) {
            emit log_named_uint("Rounding loss (wei)", dustLoss);
        }

        // Final vulnerability verdict
        if (roundingDetected) {
            emit log_string("Vulnerability Exists: Token distribution rounding error detected");
        } else {
            emit log_string("Vulnerability not Exist: All distributions are as expected");
        }
    }
}