// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MCIToken.sol";

contract MockWETH {
    function deposit() external payable {}
    function balanceOf(address) external pure returns (uint) { return 1 ether; }
}

contract MockFactory {
    event PairCreated(address indexed tokenA, address indexed tokenB, address pair, uint);
    
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        MockPair newPair = new MockPair();
        pair = address(newPair);
        emit PairCreated(tokenA, tokenB, pair, 1);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockPair {
    function sync() external {}
}

contract MCITokenFeeTest is Test {
    MCIToken token;
    address owner = address(0x1);
    address nonOwner = address(0x2);
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock Uniswap environment
        MockWETH weth = new MockWETH();
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory), address(weth));
        
        // Patch the hardcoded router address
        vm.etch(HARDCODED_ROUTER, address(router).code);
        
        // Deploy the token contract
        vm.startPrank(owner);
        token = new MCIToken();
        vm.stopPrank();
    }

    // Helper function to get marketing fee
    function getMarketingFee() public view returns (uint256) {
        return token._MarketingFee();
    }

    // Helper function to get software fee
    function getMCISoftwareFee() public view returns (uint256) {
        return token._MCISoftwareFee();
    }

    function testOwnerCanSetExcessiveFees() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 marketingFeeBefore = getMarketingFee();
        uint256 softwareFeeBefore = getMCISoftwareFee();
        console.log("Initial Marketing Fee:", marketingFeeBefore);
        console.log("Initial Software Fee:", softwareFeeBefore);
        console.log("Current Total Fees:", marketingFeeBefore + softwareFeeBefore);

        console.log("--- TRIGGER: Set Excessive Fees ---");
        // Set fees dangerously high (90% total)
        vm.prank(owner);
        token.setMarketingFee(45); // 45%
        
        vm.prank(owner);
        token.setMCISoftwareFee(45); // 45%
        console.log("Called setMarketingFee(45) and setMCISoftwareFee(45)");

        console.log("--- AFTER-Trigger State ---");
        uint256 marketingFeeAfter = getMarketingFee();
        uint256 softwareFeeAfter = getMCISoftwareFee();
        uint256 totalAfter = marketingFeeAfter + softwareFeeAfter;
        console.log("New Marketing Fee:", marketingFeeAfter);
        console.log("New Software Fee:", softwareFeeAfter);
        console.log("New Total Fees:", totalAfter);

        console.log("--- State Change Report ---");
        bool significantChange = (marketingFeeAfter - marketingFeeBefore >= 45) && 
                                (softwareFeeAfter - softwareFeeBefore >= 45);
        bool excessiveTotal = totalAfter >= 90;
        console.log("Fees increased by 45%+ each:", significantChange);
        console.log("Total fees reached 90%+:", excessiveTotal);

        // Final vulnerability verdict
        if (excessiveTotal) {
            console.log("Vulnerability Exists: Owner can set excessive fees (90%)");
        } else {
            console.log("Vulnerability not Exist: Fees remain at safe level");
        }

        // Original assertions (retained)
        assertEq(marketingFeeAfter, 45, "Marketing fee not set to dangerous level");
        assertEq(softwareFeeAfter, 45, "Software fee not set to dangerous level");
        assertEq(totalAfter, 90, "Combined fees exceed safe threshold");
    }

    function testNonOwnerCannotManipulateFees() public {
        // Non-owner attempts to set fees
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMarketingFee(35);
        
        vm.prank(nonOwner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMCISoftwareFee(45);
    }
}