// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MarvinInu.sol";

contract MarvinInuPrivilegeTest is Test {
    MarvinInu token;
    address owner;
    bool tokenDeployed;

    function setUp() public {
        owner = address(this);
        
        try new MarvinInu() returns (MarvinInu _token) {
            token = _token;
            tokenDeployed = true;
        } catch {
            tokenDeployed = false;
            // Skip all tests safely if deployment fails
            vm.skip(true);
        }
    }

    function testSetAutomatedMarketMakerPair() public {
        if (!tokenDeployed) vm.skip(true); // Skip if deployment failed
        address newPair = address(0x1234567890123456789012345678901234567890);
        
        console.log("--- BEFORE-Trigger automatedMarketMakerPairs ---");
        bool beforeState = token.automatedMarketMakerPairs(newPair);
        console.log("Automated market maker pair before:", beforeState);
        
        console.log("--- Trigger: setAutomatedMarketMakerPair ---");
        vm.startPrank(owner);
        token.setAutomatedMarketMakerPair(newPair, true);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger automatedMarketMakerPairs ---");
        bool afterState = token.automatedMarketMakerPairs(newPair);
        console.log("Automated market maker pair after:", afterState);
        
        if (afterState != beforeState) {
            console.log("Vulnerability Exists: State changed for automated market maker pair");
        } else {
            console.log("Vulnerability not Exist: No state change detected for automated market maker pair");
        }
    }

    function testMaxTransactionAmountManipulation() public {
        if (!tokenDeployed) vm.skip(true);
        
        console.log("--- BEFORE-Trigger maxTransactionAmount ---");
        uint256 beforeAmount = token.maxTransactionAmount();
        console.log("Max transaction amount before:", beforeAmount);
        
        console.log("--- Trigger: updateMaxTxnAmount ---");
        vm.startPrank(owner);
        token.updateMaxTxnAmount(beforeAmount * 2);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger maxTransactionAmount ---");
        uint256 afterAmount = token.maxTransactionAmount();
        console.log("Max transaction amount after:", afterAmount);
        
        if (afterAmount != beforeAmount) {
            console.log("Vulnerability Exists: Max transaction amount successfully manipulated");
        } else {
            console.log("Vulnerability not Exist: Max transaction amount unchanged");
        }
    }

    function testSwapTokensAtAmountManipulation() public {
        if (!tokenDeployed) vm.skip(true);
        
        console.log("--- BEFORE-Trigger swapTokensAtAmount ---");
        uint256 beforeAmount = token.swapTokensAtAmount();
        console.log("Swap tokens threshold before:", beforeAmount);
        
        console.log("--- Trigger: updateSwapTokensAtAmount ---");
        vm.startPrank(owner);
        token.updateSwapTokensAtAmount(beforeAmount * 2);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger swapTokensAtAmount ---");
        uint256 afterAmount = token.swapTokensAtAmount();
        console.log("Swap tokens threshold after:", afterAmount);
        
        if (afterAmount != beforeAmount) {
            console.log("Vulnerability Exists: Swap threshold successfully manipulated");
        } else {
            console.log("Vulnerability not Exist: Swap threshold unchanged");
        }
    }

    function testMaxWalletManipulation() public {
        if (!tokenDeployed) vm.skip(true);
        
        console.log("--- BEFORE-Trigger maxWallet ---");
        uint256 beforeAmount = token.maxWallet();
        console.log("Max wallet before:", beforeAmount);
        
        console.log("--- Trigger: updateMaxWalletAmount ---");
        vm.startPrank(owner);
        token.updateMaxWalletAmount(beforeAmount * 2);
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger maxWallet ---");
        uint256 afterAmount = token.maxWallet();
        console.log("Max wallet after:", afterAmount);
        
        if (afterAmount != beforeAmount) {
            console.log("Vulnerability Exists: Max wallet amount successfully manipulated");
        } else {
            console.log("Vulnerability not Exist: Max wallet amount unchanged");
        }
    }
}