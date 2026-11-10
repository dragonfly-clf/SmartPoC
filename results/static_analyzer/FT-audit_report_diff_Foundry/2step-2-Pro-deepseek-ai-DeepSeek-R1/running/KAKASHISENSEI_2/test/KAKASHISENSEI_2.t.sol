// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KAKASHISENSEI.sol";

contract MockFactory {
    function createPair(address tokenA, address tokenB) external pure returns (address) {
        tokenA; tokenB; // Suppress compiler warnings
        return address(0x123456); // Return mock pair address
    }
}

contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) public {
        factory = _factory;
    }
}

contract KAKASHISENSEITest is Test {
    KAKASHISENSEI token;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function getContractCode(address _addr) internal view returns (bytes memory) {
        uint256 size;
        bytes memory code;
        assembly {
            size := extcodesize(_addr)
        }
        code = new bytes(size);
        assembly {
            extcodecopy(_addr, add(code, 0x20), 0, size)
        }
        return code;
    }
    
    function setUp() public {
        // Deploy mock system
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Get bytecode using assembly bypass
        bytes memory routerCode = getContractCode(address(mockRouter));
        
        // Patch router address with mock implementation
        vm.etch(ROUTER_ADDRESS, routerCode);
        
        // Deploy token contract (uses patched router)
        token = new KAKASHISENSEI();
    }
    
    function testFeeManipulation() public {
        uint256 max = type(uint256).max;
        
        // Pre-trigger state snapshot
        emit log("--- BEFORE-Trigger Fee Setting ---");
        uint256 preBuyAdFee = token._buyAdvestisementFee();
        uint256 preSellAdFee = token._sellAdvestisementFee();
        uint256 preBuyTaxFee = token._buyTaxFee();
        uint256 preSellTaxFee = token._sellTaxFee();
        uint256 preBuyBurnFee = token._buyBurnFee();
        uint256 preSellBurnFee = token._sellBurnFee();
        
        emit log_named_uint("Pre-trigger buyAdFee", preBuyAdFee);
        emit log_named_uint("Pre-trigger sellAdFee", preSellAdFee);
        emit log_named_uint("Pre-trigger buyTaxFee", preBuyTaxFee);
        emit log_named_uint("Pre-trigger sellTaxFee", preSellTaxFee);
        emit log_named_uint("Pre-trigger buyBurnFee", preBuyBurnFee);
        emit log_named_uint("Pre-trigger sellBurnFee", preSellBurnFee);

        emit log("--- Trigger: Owner Setting Max Fees ---");
        // Verify owner can set maximum fees
        vm.prank(token.owner());
        token.setAdvestisementFeePercent(max, max);
        
        vm.prank(token.owner());
        token.setTaxFeePercent(max, max);
        
        vm.prank(token.owner());
        token.setBurnFee(max, max);

        // Post-trigger state snapshot
        emit log("--- AFTER-Trigger Fee Setting ---");
        uint256 postBuyAdFee = token._buyAdvestisementFee();
        uint256 postSellAdFee = token._sellAdvestisementFee();
        uint256 postBuyTaxFee = token._buyTaxFee();
        uint256 postSellTaxFee = token._sellTaxFee();
        uint256 postBuyBurnFee = token._buyBurnFee();
        uint256 postSellBurnFee = token._sellBurnFee();
        
        emit log_named_uint("Post-trigger buyAdFee", postBuyAdFee);
        emit log_named_uint("Post-trigger sellAdFee", postSellAdFee);
        emit log_named_uint("Post-trigger buyTaxFee", postBuyTaxFee);
        emit log_named_uint("Post-trigger sellTaxFee", postSellTaxFee);
        emit log_named_uint("Post-trigger buyBurnFee", postBuyBurnFee);
        emit log_named_uint("Post-trigger sellBurnFee", postSellBurnFee);

        // Vulnerability verification
        bool vulnerable = true;
        if (postBuyAdFee != max) {
            emit log("buyAdFee not set to max");
            vulnerable = false;
        }
        if (postSellAdFee != max) {
            emit log("sellAdFee not set to max");
            vulnerable = false;
        }
        if (postBuyTaxFee != max) {
            emit log("buyTaxFee not set to max");
            vulnerable = false;
        }
        if (postSellTaxFee != max) {
            emit log("sellTaxFee not set to max");
            vulnerable = false;
        }
        if (postBuyBurnFee != max) {
            emit log("buyBurnFee not set to max");
            vulnerable = false;
        }
        if (postSellBurnFee != max) {
            emit log("sellBurnFee not set to max");
            vulnerable = false;
        }

        // Non-owner test (preserved from original)
        emit log("--- Testing Non-Owner Access ---");
        address attacker = address(0xBAD);
        vm.startPrank(attacker);
        
        vm.expectRevert();
        token.setAdvestisementFeePercent(1, 1);
        
        vm.expectRevert();
        token.setTaxFeePercent(1, 1);
        
        vm.expectRevert();
        token.setBurnFee(1, 1);

        // Final verdict
        if (vulnerable) {
            emit log("Vulnerability Exists: Owner can set fees to excessive max value");
        } else {
            emit log("Vulnerability not Exist: Max fee setting failed for some parameters");
        }
    }
}