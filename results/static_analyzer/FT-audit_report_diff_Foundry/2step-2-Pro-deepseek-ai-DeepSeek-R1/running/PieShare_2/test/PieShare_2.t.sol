// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PieShare.sol";

contract PieShareFeeTest is Test {
    PieShare token;
    address owner = address(this);
    address user = address(0x1);
    address anotherUser = address(0x3);
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    // Mock addresses
    address mockWETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address mockFactory = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address mockPair = 0x58F876857a02D6762E0101bb5C46A8c1ED44Dc16;

    function setUp() public {
        // Setup Uniswap mocks
        bytes4 factorySelector = bytes4(keccak256("factory()"));
        vm.mockCall(
            ROUTER,
            abi.encodePacked(factorySelector),
            abi.encode(mockFactory)
        );
        
        bytes4 wethSelector = bytes4(keccak256("WETH()"));
        vm.mockCall(
            ROUTER,
            abi.encodePacked(wethSelector),
            abi.encode(mockWETH)
        );
        
        // Mock createPair calls
        bytes4 createPairSelector = bytes4(keccak256("createPair(address,address)"));
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(createPairSelector),
            abi.encode(mockPair)
        );

        // Deploy token
        token = new PieShare();

        // Set max wallet tokens to avoid transfer restrictions
        token.setMaxWalletTokens(type(uint256).max);
        
        // Transfer tokens to user
        uint256 decimals = token.decimals();
        uint256 amount = 100000 * (10 ** uint256(decimals));
        vm.prank(owner);
        token.transfer(user, amount);
    }

    function testFeeOverflowRevertsTransfer() public {
        // Set fees to 101% (totalFees will exceed 100%)
        vm.startPrank(owner);
        token.setLiquidityFee(101);
        token.setBUSDRewardsFee(0);
        token.setBuybackFee(0);
        token.setMarketingFee(0);
        vm.stopPrank();

        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 transferAmount = 100 * (10 ** uint256(token.decimals()));
        uint256 balanceBefore = token.balanceOf(anotherUser);
        console.log("Recipient balance before transfer:", balanceBefore);

        console.log("--- Trigger Transfer ---");
        console.log("Performing transfer (expected to revert)");
        vm.startPrank(user);
        vm.expectRevert("SafeMath: subtraction overflow");
        token.transfer(anotherUser, transferAmount);
        vm.stopPrank();
        console.log("Transfer reverted as expected");

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 balanceAfter = token.balanceOf(anotherUser);
        console.log("Recipient balance after transfer:", balanceAfter);

        bool balanceUnchanged = (balanceAfter == balanceBefore);
        console.log("Balance unchanged:", balanceUnchanged ? "YES" : "NO");
        
        if (balanceUnchanged) {
            console.log("Vulnerability Exists: Transfer reverts when total fee exceeds 100%");
        } else {
            console.log("Vulnerability not Exist: Transfer modified recipient balance unexpectedly");
        }
    }
}