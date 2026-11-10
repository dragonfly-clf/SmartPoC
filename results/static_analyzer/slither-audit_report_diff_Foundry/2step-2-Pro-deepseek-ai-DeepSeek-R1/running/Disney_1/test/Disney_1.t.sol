// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract MathTester {
    // This is the VULNERABLE version that uses XOR (^) instead of exponentiation (**)
    function mulDivVulnerable(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public pure returns (uint256 result) {
        unchecked {
            // 512-bit multiply [prod1 prod0] = x * y. Compute the product mod 2^256 and mod 2^256 - 1
            uint256 prod0; // Least significant 256 bits of the product
            uint256 prod1; // Most significant 256 bits of the product
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            // Skip if there's no overflow
            if (prod1 == 0) {
                return prod0 / denominator;
            }

            require(denominator > prod1, "Denominator must be > prod1");

            // Make division exact by subtracting remainder from [prod1 prod0]
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            // Factor powers of two out of denominator
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, twos)
                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }

            // Shift bits from prod1 into prod0
            prod0 |= prod1 * twos;

            // VULNERABLE: Using XOR (^) for inverse calculation
            uint256 inverse = (3 * denominator) ^ 2;

            // Newton-Raphson iterations (remain unchanged)
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;

            result = prod0 * inverse;
        }
    }

    // This is the CORRECTED version using exponentiation (**)
    function mulDivCorrected(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) public pure returns (uint256 result) {
        unchecked {
            uint256 prod0;
            uint256 prod1;
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }

            if (prod1 == 0) {
                return prod0 / denominator;
            }

            require(denominator > prod1, "Denominator must be > prod1");

            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }

            uint256 twos = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, twos)
                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }

            prod0 |= prod1 * twos;

            // CORRECTED: Using exponentiation (**) for inverse calculation
            uint256 inverse = (3 * denominator) ** 2;

            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;
            inverse *= 2 - denominator * inverse;

            result = prod0 * inverse;
        }
    }
}

contract DisneyTest is Test {
    MathTester mathTester;

    function setUp() public {
        mathTester = new MathTester();
    }

    function test_MulDivIncorrectExponentiation() public {
        // Use sufficiently large numbers to trigger overflow case
        uint256 x = 2**156 + 1; // Causes multiplication overflow > 256 bits
        uint256 y = 2**100;
        uint256 denominator = 15; // Non power-of-two denominator
        
        console2.log("--- BEFORE-Trigger ---");
        console2.log("Input parameters:");
        console2.log("x: %s", x);
        console2.log("y: %s", y);
        console2.log("denominator: %s", denominator);
        console2.log();
        
        console2.log("--- Trigger (Vulnerable Function) ---");
        uint256 resultVulnerable = mathTester.mulDivVulnerable(x, y, denominator);
        console2.log("Vulnerable function result: %s", resultVulnerable);
        console2.log();
        
        console2.log("--- Trigger (Corrected Function) ---");
        uint256 resultCorrected = mathTester.mulDivCorrected(x, y, denominator);
        console2.log("Corrected function result: %s", resultCorrected);
        console2.log();
        
        console2.log("--- Comparison ---");
        console2.log("Vulnerable result : %s", resultVulnerable);
        console2.log("Corrected result  : %s", resultCorrected);
        console2.log();
        
        if (resultVulnerable != resultCorrected) {
            console2.log("Vulnerability Exists: Results differ between implementations");
        } else {
            revert("Vulnerability not Exist: Results are identical");
        }
    }
}