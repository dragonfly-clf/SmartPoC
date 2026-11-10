// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaMew.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x9abc);
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1234);
    }
    
    function WETH() external pure returns (address) {
        return address(0x5678);
    }
}

contract MetaMewTest is Test {
    MetaMew public token;
    address owner = address(0x1);
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock contracts at required addresses
        vm.etch(address(0x1234), type(MockFactory).runtimeCode);  // Factory
        vm.etch(routerAddress, type(MockRouter).runtimeCode);     // Router

        // Deploy token
        vm.prank(owner);
        token = new MetaMew();
    }

    function testFeeCanExceed25Percent() public {
        console.log("--- BEFORE-Trigger Attack ---");
        // Get current sell tax fee
        uint256 initialFee = token._sellTaxFee();
        console.log("Initial sellTaxFee: %s%%, expected to be within limits", initialFee);
        
        console.log("--- Trigger Attack: setSellTaxFeePerecent(50) ---");
        // Attempt to set tax fee to 50% (exceeding 25% limit)
        vm.prank(owner);
        token.setSellTaxFeePerecent(50);  // Proof of vulnerability if no revert

        console.log("--- AFTER-Trigger Attack ---");
        // Get sell tax fee after attack
        uint256 afterFee = token._sellTaxFee();
        console.log("Updated sellTaxFee: %s%%", afterFee);

        // Vulnerability exists if fee was set to 50%
        if (afterFee == 50) {
            console.log("Vulnerability Exists: Owner successfully set fee to 50%, exceeding 25% limit");
        } else {
            console.log("Vulnerability not Exist: Fee set to %s%%, possibly within limit", afterFee);
        }
    }
}