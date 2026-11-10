// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/FortuneCookieV2.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }

    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract FortuneCookieV2Test is Test {
    FortuneCookieV2 token;
    address deployer;
    address recipient = address(0xDEADBEEF);

    function setUp() public {
        deployer = address(this);
        
        // Create mock Uniswap contracts
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter();

        // Assign mock contracts to PancakeSwap addresses
        address routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        vm.etch(routerAddress, address(mockRouter).code);
        
        address factoryAddress = mockRouter.factory();
        vm.etch(factoryAddress, address(mockFactory).code);
        
        // Deploy token contract
        token = new FortuneCookieV2();
    }

    function testAirdropDuplicateAddress() public {
        // Prepare airdrop data with duplicate entries
        address[] memory recipients = new address[](2);
        uint256[] memory amounts = new uint256[](2);
        recipients[0] = recipient;
        recipients[1] = recipient;
        amounts[0] = 100;
        amounts[1] = 100;

        // Ensure recipient can receive airdrop
        vm.prank(deployer);
        token.excludeFromFee(recipient);
        
        console.log("--- BEFORE-Trigger Airdrop ---");
        uint256 initialBalance = token.balanceOf(recipient);
        console.log("Recipient initial balance:", initialBalance);

        console.log("--- Trigger Airdrop ---");
        vm.prank(deployer);
        token.airDrop(recipients, amounts);
        
        console.log("--- AFTER-Trigger Airdrop ---");
        uint256 finalBalance = token.balanceOf(recipient);
        console.log("Recipient final balance:", finalBalance);
        uint256 balanceChange = finalBalance - initialBalance;
        console.log("Actual balance change:", balanceChange);

        bool vulnerabilityExists = balanceChange == 200;
        console.log("Vulnerability exists:", vulnerabilityExists ? "YES" : "NO");

        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Duplicate airdrop addresses received multiple tokens");
        } else {
            console.log("Vulnerability not Exist: Duplicate addresses only received one airdrop");
        }
    }
}