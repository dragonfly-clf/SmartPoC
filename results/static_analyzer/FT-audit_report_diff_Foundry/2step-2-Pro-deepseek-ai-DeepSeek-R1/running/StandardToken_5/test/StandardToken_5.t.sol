// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StandardToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address pair) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract MockRouter {
    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function addLiquidityETH(
        address, // token
        uint256, // amountTokenDesired
        uint256, // amountTokenMin
        uint256, // amountETHMin
        address, // to
        uint256  // deadline
    ) external payable returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, // amountIn
        uint256, // amountOutMin
        address[] calldata, // path
        address, // to
        uint256  // deadline
    ) external {
        // Do nothing
    }
}

contract StandardTokenSetFeesTest is Test {
    StandardToken token;
    address owner = makeAddr("owner");
    address nonOwner = makeAddr("nonOwner");

    // Hardcoded router address from token
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create mock router dependencies
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Etch mock router to hardcoded address
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Initialize factory storage at router address (slot 0)
        bytes32 factorySlot = bytes32(uint256(0));
        bytes32 factoryValue = bytes32(uint256(uint160(address(mockFactory))));
        vm.store(ROUTER_ADDRESS, factorySlot, factoryValue);

        // Deploy token contract
        vm.startPrank(owner);
        token = new StandardToken(owner);
        vm.stopPrank();
    }

    // Helper to query and log fee state using uint256
    function _getFees() internal view returns (uint256 liquidityFee, uint256 holdersFee, uint256 burnFee, uint256 totalFee, uint256 feeDenominator) {
        (liquidityFee, holdersFee, burnFee, totalFee, feeDenominator) = token.fees();
        return (liquidityFee, holdersFee, burnFee, totalFee, feeDenominator);
    }

    function _logFees(string memory description, uint256 liquidityFee, uint256 holdersFee, uint256 burnFee, uint256 totalFee, uint256 feeDenominator) internal {
        console.log(description);
        console.log("  liquidityFee:   ", liquidityFee);
        console.log("  holdersFee:     ", holdersFee);
        console.log("  burnFee:        ", burnFee);
        console.log("  totalFee:       ", totalFee);
        console.log("  feeDenominator: ", feeDenominator);
    }

    function test_owner_can_set_denominator_to_zero() public {
        (uint256 liqBefore, uint256 holdBefore, uint256 burnBefore, uint256 totalBefore, uint256 denomBefore) = _getFees();
        _logFees("--- BEFORE-Trigger Fees ---", liqBefore, holdBefore, burnBefore, totalBefore, denomBefore);

        console.log("--- Trigger Change ---");
        vm.prank(owner);
        token.setFees(0, 0, 0, 0); // Should not revert

        (uint256 liqAfter, uint256 holdAfter, uint256 burnAfter, uint256 totalAfter, uint256 denomAfter) = _getFees();
        _logFees("--- AFTER-Trigger Fees ---", liqAfter, holdAfter, burnAfter, totalAfter, denomAfter);

        // Vulnerability verification
        if (liqAfter == 0 && holdAfter == 0 && burnAfter == 0 && denomAfter == 0) {
            console.log("Vulnerability Exists: Fee parameters set to zero by owner");
        } else {
            console.log("Vulnerability not Exist: Fee zero-setting prevention works");
        }
    }

    function test_non_owner_cannot_set_fees() public {
        (uint256 liqBefore, uint256 holdBefore, uint256 burnBefore, uint256 totalBefore, uint256 denomBefore) = _getFees();
        _logFees("--- BEFORE-Trigger Fees ---", liqBefore, holdBefore, burnBefore, totalBefore, denomBefore);

        console.log("--- Trigger Change ---");
        vm.prank(nonOwner);
        vm.expectRevert();
        token.setFees(30,20,0,100);

        (uint256 liqAfter, uint256 holdAfter, uint256 burnAfter, uint256 totalAfter, uint256 denomAfter) = _getFees();
        _logFees("--- AFTER-Trigger Fees ---", liqAfter, holdAfter, burnAfter, totalAfter, denomAfter);

        // Vulnerability verification
        if(
            liqAfter == liqBefore &&
            holdAfter == holdBefore &&
            burnAfter == burnBefore &&
            totalAfter == totalBefore &&
            denomAfter == denomBefore
        ) {
            console.log("Vulnerability not Exist: Non-owner access prevented");
        } else {
            console.log("Vulnerability Exists: Non-owner modified fees");
        }
    }

    function test_owner_can_set_zero_burn_fee() public {
        (uint256 liqBefore, uint256 holdBefore, uint256 burnBefore, uint256 totalBefore, uint256 denomBefore) = _getFees();
        _logFees("--- BEFORE-Trigger Fees ---", liqBefore, holdBefore, burnBefore, totalBefore, denomBefore);

        console.log("--- Trigger Change ---");
        vm.prank(owner);
        token.setFees(30,20,0,100);

        (uint256 liqAfter, uint256 holdAfter, uint256 burnAfter, uint256 totalAfter, uint256 denomAfter) = _getFees();
        _logFees("--- AFTER-Trigger Fees ---", liqAfter, holdAfter, burnAfter, totalAfter, denomAfter);

        // Vulnerability verification
        if (burnAfter == 0 && totalAfter == 50) {
            console.log("Vulnerability Exists: Burn fee set to zero by owner");
        } else {
            console.log("Vulnerability not Exist: Burn fee protection works");
        }
    }

    function test_owner_can_set_unreasonably_high_fees() public {
        (uint256 liqBefore, uint256 holdBefore, uint256 burnBefore, uint256 totalBefore, uint256 denomBefore) = _getFees();
        _logFees("--- BEFORE-Trigger Fees ---", liqBefore, holdBefore, burnBefore, totalBefore, denomBefore);

        console.log("--- Trigger Change ---");
        vm.prank(owner);
        token.setFees(40,30,30,100);

        (uint256 liqAfter, uint256 holdAfter, uint256 burnAfter, uint256 totalAfter, uint256 denomAfter) = _getFees();
        _logFees("--- AFTER-Trigger Fees ---", liqAfter, holdAfter, burnAfter, totalAfter, denomAfter);

        // Vulnerability verification
        if (totalAfter == 100) {
            console.log("Vulnerability Exists: Total fee set to 100% by owner");
        } else {
            console.log("Vulnerability not Exist: Total fee cap works");
        }
    }
}