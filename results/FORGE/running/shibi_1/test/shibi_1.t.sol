// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHIBI.sol";

contract MockUniswap {
    function factory() public view returns (address) {
        return address(this);
    }

    function WETH() public pure returns (address) {
        return address(0);
    }

    function createPair(address, address) public pure returns (address) {
        return address(0xC0FFEE);
    }
}

contract SHIBITest is Test {
    SHIBI token;
    address owner = address(0xa11ce);
    address constant pancakeRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function _getCode(address _addr) private view returns (bytes memory) {
        uint256 size;
        assembly { size := extcodesize(_addr) }
        bytes memory code = new bytes(size);
        assembly { extcodecopy(_addr, add(code, 0x20), 0, size) }
        return code;
    }

    function setUp() public {
        MockUniswap mock = new MockUniswap();
        bytes memory code = _getCode(address(mock));
        vm.etch(pancakeRouter, code);

        vm.startPrank(owner);
        token = new SHIBI();
        vm.stopPrank();
    }

    function testTaxFeeManipulation() public {
        // Initial fee check
        console.log("--- BEFORE-Trigger Tax Fee ---");
        uint256 initialTaxFee = token._taxFee();
        console.log("Initial tax fee value:", initialTaxFee);

        console.log("--- Trigger Fee Manipulation ---");
        vm.startPrank(owner);
        token.setTaxFeePercent(26); // Exceeds 25% without restriction
        token.setTaxFeePercent(100); // Sets to extremely high value
        vm.stopPrank();

        // Final fee check
        console.log("--- AFTER-Trigger Tax Fee ---");
        uint256 manipulatedTaxFee = token._taxFee();
        console.log("Manipulated tax fee value:", manipulatedTaxFee);

        // Vulnerability verification
        bool feeExceedsLimit = manipulatedTaxFee > 25;
        console.log("Tax fee exceeds 25%% limit:", feeExceedsLimit ? "YES" : "NO");

        // Final verdict
        if (feeExceedsLimit) {
            console.log("Vulnerability Exists: Owner can set transaction fee beyond limit (>25%%)");
        } else {
            console.log("Vulnerability not Exist: Fee limits are properly enforced");
        }
    }
}