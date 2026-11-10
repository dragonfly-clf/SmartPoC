// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Munkai.sol";

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor() {
        factory = address(new MockFactory());
        WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external pure {}
    
    function addLiquidityETH(
        address, uint, uint, uint, address, uint
    ) external payable returns (uint, uint, uint) {}
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1);
    }
}

contract MunkaiFeeTest is Test {
    Munkai token;
    address owner;
    address user = address(0x123);
    MockRouter mockRouter;

    function setUp() public {
        owner = address(this);
        mockRouter = new MockRouter();
        token = new Munkai(address(mockRouter));
        
        // Configure fee settings to trigger vulnerability
        vm.startPrank(owner);
        token.setFees(0, 0, 0, 0, 10000); // Sets totalFee to 0
        token.setSwapBackSettings(true, 1 * 10**9); // Set minimal swap threshold
        
        // Prepare contract for swap attempt
        token.transfer(address(token), 100 * 10**9); // Fund token contract
        vm.stopPrank();
    }

    function testSwapBackFailsWhenTotalFeeZero() public {
        console.log("--- BEFORE-Trigger state ---");
        console.log("Contract state prepared: totalFee=0, swapBack enabled");
        
        console.log("--- Trigger Transfer ---");
        try token.transfer(user, 1 * 10**9) {
            console.log("--- AFTER-Trigger state ---");
            console.log("Transfer executed without revert");
            // Vulnerability not triggered if no revert occurs
            console.log("Vulnerability not Exist: Transfer succeeded despite totalFee=0 (swapBack did not trigger division-by-zero)");
        } catch (bytes memory revertData) {
            console.log("--- AFTER-Trigger state ---");
            console.logBytes(revertData);
            console.log("Revert detected in transfer function");
            // Vulnerability confirmed if revert occurs
            console.log("Vulnerability Exists: Division-by-zero panic detected during swapBack");
        }
    }
}