// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/JOKECOMMUNITY.sol";

contract JOKEFeeTest is Test {
    JOKECOMMUNITY token;
    address constant mockRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock contract for router
        MockUniswapV2RouterAndFactory mock = new MockUniswapV2RouterAndFactory();
        
        // Use assembly to get runtime bytecode
        bytes memory code = getCode(address(mock));
        
        // Apply mock code to the predefined router address
        vm.etch(mockRouter, code);
        
        // Deploy token contract
        token = new JOKECOMMUNITY();
    }

    function testUnlimitedTaxFeeIncrease() public {
        // Query tax fee before set
        uint256 taxFeeBefore = token._taxFee();
        console.log("--- BEFORE: initial taxFee ---");
        console.log(taxFeeBefore);

        console.log("--- TRIGGER: setTaxFee(1), setTaxFee(100), setTaxFee(200) ---");
        // Should not revert when increasing fee beyond 100%
        token.setTaxFee(1);
        token.setTaxFee(100);
        token.setTaxFee(200);

        // Query tax fee after set
        uint256 taxFeeAfter = token._taxFee();
        console.log("--- AFTER: final taxFee ---");
        console.log(taxFeeAfter);
        
        // Evaluate vulnerability existence
        if (taxFeeAfter == 200) {
            console.log("Vulnerability Exists: Tax fee was set beyond 100% to 200%");
        } else {
            console.log("Vulnerability not Exist: TaxFee remains %s after operations", taxFeeAfter);
        }
    }

    function testZeroTaxFeeReverts() public {
        // Should revert when trying to set zero fee
        vm.expectRevert("newTaxFee can not be Zero amount");
        token.setTaxFee(0);
    }

    // Helper to get contract bytecode
    function getCode(address _addr) internal view returns (bytes memory o_code) {
        uint size;
        assembly {
            size := extcodesize(_addr)
        }
        o_code = new bytes(size);
        assembly {
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
        }
    }
}

contract MockUniswapV2RouterAndFactory {
    function factory() external view returns (address) {
        return address(this);
    }
    
    function WETH() external pure returns (address) {
        return address(0xBEEF);
    }
    
    function createPair(address, address) external pure returns (address) {
        return address(0xCAFE);
    }
}