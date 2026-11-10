// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CharlaCoin.sol";

contract CharlaCoinTest is Test {
    CharlaCoin token;
    address owner = address(this);
    address user1 = address(0x1);
    address user2 = address(0x2);
    address mockPair = address(0x789); // Matching with mock factory's pair address

    function setUp() public {
        // Mock router and factory addresses
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(new MockUniswapRouter()).code);
        vm.etch(0x1111111111222222222233333333334444444444, address(new MockUniswapFactory()).code);

        // Deploy token
        token = new CharlaCoin();
        
        // Configurations
        token.setMarketPairStatus(mockPair, true);
        token.setSwapAndLiquifyEnabled(false);
        
        // Use 15% of total supply instead of fixed amounts
        uint256 ownerBalance = token.balanceOf(owner);
        uint256 transferAmount = ownerBalance * 15 / 100;
        token.transfer(user1, transferAmount);
        
        // Disable maxTxAmount by default
        token.setMaxTxAmount(type(uint256).max);
    }

    function testSetMaxTxAmountToZero() public {
        token.setMaxTxAmount(0);
        
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        vm.prank(user1);
        token.transfer(user2, 1);
    }

    function testSetSellTaxTo100() public {
        // BEFORE: Record initial token balances
        uint256 initialUser1Balance = token.balanceOf(user1);
        uint256 initialContractBalance = token.balanceOf(address(token));
        
        console.log("--- BEFORE-Trigger ---");
        console.log("User1 balance:", initialUser1Balance);
        console.log("Token contract tax balance:", initialContractBalance);

        console.log("--- TRIGGER: Setting 100 sell tax and executing transfer ---");
        token.setSellTaxes(0, 100, 0); // 100% sell tax
        uint256 userBalance = token.balanceOf(user1);

        vm.prank(user1);
        token.transfer(mockPair, userBalance);

        // AFTER: Get final balances
        uint256 finalUser1Balance = token.balanceOf(user1);
        uint256 finalContractBalance = token.balanceOf(address(token));
        
        console.log("--- AFTER-Trigger ---");
        console.log("User1 balance:", finalUser1Balance);
        console.log("Token contract tax balance:", finalContractBalance);
        
        // Verify balance differences
        bool balanceDrained = finalUser1Balance == 0;
        bool taxCaptured = finalContractBalance == initialContractBalance + initialUser1Balance;
        
        console.log("Balance drained to zero:", balanceDrained ? "SUCCESS (Vulnerability Exists)" : "FAILURE (Vulnerability not Exist)");
        console.log("Tax captured correctly:", taxCaptured ? "SUCCESS (Vulnerability Exists)" : "FAILURE (Vulnerability not Exist)");
        
        // Final vulnerability determination
        if (balanceDrained && taxCaptured) {
            console.log("Vulnerability Exists: Successfully set 100 sell tax and transferred all user funds as tax");
        } else {
            console.log("Vulnerability not Exist: Tax mechanism did not work as expected");
        }
    }
}

contract MockUniswapRouter {
    function factory() external pure returns (address) {
        return address(0x1111111111222222222233333333334444444444);
    }
    function WETH() external pure returns (address) {
        return address(0x2222222222333333333344444444445555555555);
    }
}

contract MockUniswapFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}