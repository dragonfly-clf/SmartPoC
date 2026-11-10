// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PuppySwapToken.sol";

contract MockRouter {
    address public factory;
    address public immutable WETH;
    
    constructor() public {
        factory = address(new MockFactory());
        WETH = address(0xDEAD);
    }
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0xCAFEBABE);
    }
}

contract PuppySwapTokenTest is Test {
    PuppySwapToken token;
    address owner = address(0x1);

    function setUp() public {
        vm.startPrank(owner);
        token = new PuppySwapToken(payable(address(new MockRouter())));
        vm.stopPrank();
    }

    function testExcessiveFeeManipulation() public {
        // Pre-trigger state snapshot
        emit log("--- BEFORE-Trigger Fees ---");
        uint256 initialLiquidityFee = token._liquidityFee();
        uint256 initialTaxFee = token._taxFee();
        emit log_named_uint("Initial Liquidity Fee", initialLiquidityFee);
        emit log_named_uint("Initial Tax Fee", initialTaxFee);

        emit log("--- Trigger Fee Manipulation ---");
        vm.startPrank(owner);
        try token.setLiquidityFeePercent(100) {
            emit log_string("Successfully set liquidity fee to 100%");
        } catch {
            fail("setLiquidityFeePercent should not revert");
        }

        try token.setTaxFeePercent(100) {
            emit log_string("Successfully set tax fee to 100%");
        } catch {
            fail("setTaxFeePercent should not revert");
        }
        vm.stopPrank();

        // Post-trigger state snapshot
        emit log("--- AFTER-Trigger Fees ---");
        uint256 finalLiquidityFee = token._liquidityFee();
        uint256 finalTaxFee = token._taxFee();
        emit log_named_uint("Final Liquidity Fee", finalLiquidityFee);
        emit log_named_uint("Final Tax Fee", finalTaxFee);

        // Differential verification
        emit log("--- Differential Results ---");
        bool liquidityFeeChanged = (finalLiquidityFee == 100);
        bool taxFeeChanged = (finalTaxFee == 100);
        
        emit log_named_string("Liquidity fee reached 100%", liquidityFeeChanged ? "YES" : "NO");
        emit log_named_string("Tax fee reached 100%", taxFeeChanged ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (liquidityFeeChanged || taxFeeChanged) {
            emit log("Vulnerability Exists: Owner can set fee rates beyond reasonable limits (100%)");
        } else {
            emit log("Vulnerability not Exist: Fee setters enforce proper upper bounds");
        }
    }
}