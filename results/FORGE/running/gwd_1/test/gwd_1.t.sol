// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GREENWORLD.sol";

contract GREENWORLDTest is Test {
    GREENWORLD token;
    address owner = address(0x0001);
    address mockRouter = address(0x1000);
    address mockFactory = address(0x2000);
    address mockPair = address(0x3000);
    address mockWETH = address(0x4000);

    function setUp() public {
        vm.startPrank(owner);
        
        // Precompute token address using next nonce
        uint64 nonce = vm.getNonce(owner);
        address tokenAddress = vm.computeCreateAddress(owner, nonce);
        
        // Mock router calls
        vm.mockCall(
            mockRouter,
            abi.encodeWithSignature("factory()"), 
            abi.encode(mockFactory)
        );
        vm.mockCall(
            mockRouter, 
            abi.encodeWithSignature("WETH()"), 
            abi.encode(mockWETH)
        );
        
        // Mock factory call with precise tokenAddress
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature(
                "createPair(address,address)", 
                tokenAddress, 
                mockWETH
            ),
            abi.encode(mockPair)
        );
        
        // Deploy token contract
        token = new GREENWORLD(mockRouter);
        assertEq(address(token), tokenAddress);
        
        vm.stopPrank();
    }

    function testSetExcessiveTaxes() public {
        // Set taxes totaling 30% (3000 basis points) - exceeds 25% limit
        uint256 rfi = 600;
        uint256 charity = 600;
        uint256 liquidity = 600;
        uint256 utility = 600;
        uint256 operation = 300;
        uint256 burn = 300;
        
        uint256 total = rfi + charity + liquidity + utility + operation + burn;
        assertGt(total, 2500, "Total taxes exceed 2500 basis point limit");

        console.log("--- BEFORE-Trigger Query ---");
        // Query all current tax values individually
        (
            uint256 rfiBefore,
            uint256 charityBefore,
            uint256 liquidityBefore,
            uint256 utilityBefore,
            uint256 operationBefore,
            uint256 burnBefore
        ) = token.taxes();
        uint256 totalBefore = rfiBefore + charityBefore + liquidityBefore +
                          utilityBefore + operationBefore + burnBefore;
        
        console.log("RFI (before): %d", rfiBefore);
        console.log("Charity (before): %d", charityBefore);
        console.log("Liquidity (before): %d", liquidityBefore);
        console.log("Utility (before): %d", utilityBefore);
        console.log("Operation (before): %d", operationBefore);
        console.log("Burn (before): %d", burnBefore);
        console.log("Total basis points (before): %d", totalBefore);
        console.log("");

        console.log("--- Trigger setTaxes ---");
        vm.prank(owner);
        token.setTaxes(
            rfi,
            charity,
            liquidity,
            utility,
            operation,
            burn
        );
        console.log("Called setTaxes with total %d basis points", total);
        console.log("");

        console.log("--- AFTER-Trigger Query ---");
        // Query all tax values after trigger
        (
            uint256 rfiAfter,
            uint256 charityAfter,
            uint256 liquidityAfter,
            uint256 utilityAfter,
            uint256 operationAfter,
            uint256 burnAfter
        ) = token.taxes();
        uint256 totalAfter = rfiAfter + charityAfter + liquidityAfter +
                         utilityAfter + operationAfter + burnAfter;
        
        console.log("RFI (after): %d", rfiAfter);
        console.log("Charity (after): %d", charityAfter);
        console.log("Liquidity (after): %d", liquidityAfter);
        console.log("Utility (after): %d", utilityAfter);
        console.log("Operation (after): %d", operationAfter);
        console.log("Burn (after): %d", burnAfter);
        console.log("Total basis points (after): %d", totalAfter);

        console.log("");
        console.log("--- Differential Verification ---");
        console.log("Condition: total tax rate must be above 25% limit (2500 basis points)");
        console.log("Total tax before: %d | After: %d", totalBefore, totalAfter);
        console.log("Difference: +%d basis points", totalAfter - totalBefore);

        // Final verdict
        bool vulnerabilityExists = totalAfter > 2500;
        if (vulnerabilityExists) {
            console.log("Result: TAXES SET ABOVE 25%% LIMIT -> VULNERABILITY EXIST");
            console.log("Vulnerability Exists: The contract allows setting tax rates above 25%% limit");
        } else {
            console.log("Result: Tax rates remain within limit -> Vulnerability guard works");
            console.log("Vulnerability not Exist: Tax rates capped at or below 25%% limit");
        }
    }

    function testRevertWhenNotOwner() public {
        vm.prank(address(0x123));
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxes(0, 0, 0, 0, 0, 0);
    }
}