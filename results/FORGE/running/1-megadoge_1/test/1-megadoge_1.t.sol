// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract MockMEGADOGE {
    uint256 public DOGERewardsFee;
    uint256 public marketingFee;
    uint256 public totalFees;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function setDOGERewardsFee(uint8 value) external onlyOwner {
        DOGERewardsFee = value;
        totalFees = DOGERewardsFee + marketingFee;
    }

    function setMarketingFee(uint8 value) external onlyOwner {
        marketingFee = value;
        totalFees = DOGERewardsFee + marketingFee;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        owner = newOwner;
    }
}

contract FeeManipulationTest is Test {
    MockMEGADOGE token;
    address testOwner = makeAddr("owner");

    function setUp() public {
        token = new MockMEGADOGE();
        token.transferOwnership(testOwner);
    }

    function testCanSetFeesAbove25Percent() public {
        vm.startPrank(testOwner);

        // BEFORE: Capture initial state
        uint256 preMarketingFee = token.marketingFee();
        uint256 preTotalFees = token.totalFees();
        console2.log("--- BEFORE SetFees ---");
        console2.log("MarketingFee: %s", preMarketingFee);
        console2.log("TotalFees:    %s", preTotalFees);

        // TRIGGER: Set marketing fee to 26%
        console2.log("--- TRIGGER: setMarketingFee(26) ---");
        token.setDOGERewardsFee(0);
        token.setMarketingFee(26);

        // AFTER: Capture resulting state
        uint256 postMarketingFee = token.marketingFee();
        uint256 postTotalFees = token.totalFees();
        console2.log("--- AFTER SetFees ---");
        console2.log("MarketingFee: %s", postMarketingFee);
        console2.log("TotalFees:    %s", postTotalFees);

        // State comparison verification
        bool feesChanged = (preMarketingFee != postMarketingFee || preTotalFees != postTotalFees);
        bool feeExceedsLimit = (postTotalFees > 25);
        console2.log("State Changed:      %s", feesChanged ? "YES" : "NO");
        console2.log("Fee Exceeds 25%%:    %s", feeExceedsLimit ? "YES" : "NO");
        
        vm.stopPrank();

        // Final vulnerability verdict
        if (feeExceedsLimit) {
            console2.log("Vulnerability Exists: Marketing fee settable above 25%% limit");
        } else {
            console2.log("Vulnerability not Exist: Marketing fee within 25%% limit");
        }
    }

    function testCanSet100PercentFees() public {
        vm.startPrank(testOwner);

        // BEFORE: Capture initial state
        console2.log("--- BEFORE SetFees ---");
        uint256 preTotalFees = token.totalFees();
        console2.log("TotalFees: %s", preTotalFees);

        // TRIGGER: Set 100% fees
        console2.log("--- TRIGGER: Setting fees to 100%% ---");
        token.setDOGERewardsFee(0);
        token.setMarketingFee(100);

        // AFTER: Verify state
        uint256 postTotalFees = token.totalFees();
        console2.log("--- AFTER SetFees ---");
        console2.log("TotalFees: %s", postTotalFees);

        // Vulnerability verification
        bool is100Percent = (postTotalFees == 100);
        console2.log("100%% Fees Enabled: %s", is100Percent ? "YES" : "NO");
        
        vm.stopPrank();

        // Final verdict
        if (is100Percent) {
            console2.log("Vulnerability Exists: Fees can be set to 100%%");
        } else {
            console2.log("Vulnerability not Exist: Fees could not reach 100%%");
        }
    }

    function testFeesBeyondMaximum() public {
        vm.startPrank(testOwner);

        // BEFORE: Capture baseline
        console2.log("--- BEFORE SetExtremeFees ---");
        uint256 preTotalFees = token.totalFees();
        console2.log("Initial TotalFees: %s", preTotalFees);

        // TRIGGER: Set extreme fees
        console2.log("--- TRIGGER: Setting extreme fees (100+100) ---");
        token.setDOGERewardsFee(100);
        token.setMarketingFee(100);

        // AFTER: Check resulting state
        uint256 postTotalFees = token.totalFees();
        console2.log("--- AFTER SetExtremeFees ---");
        console2.log("Resulting TotalFees: %s", postTotalFees);

        // Vulnerability verification
        bool exceedsMaximum = (postTotalFees > 100);
        console2.log("Fees Exceed 100%%: %s", exceedsMaximum ? "YES" : "NO");
        
        vm.stopPrank();

        // Final verdict
        if (exceedsMaximum) {
            console2.log("Vulnerability Exists: Total fees exceed 100%% maximum");
        } else {
            console2.log("Vulnerability not Exist: Total fees within 100%% limit");
        }
    }
}