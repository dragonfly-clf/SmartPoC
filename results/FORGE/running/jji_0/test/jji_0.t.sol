// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/JujutsuInu.sol";

contract MockWETH {
    function deposit() public payable {}
    function withdraw(uint) public {}
}

contract MockRouter {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint, address[] calldata, address, uint
    ) external payable {}
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external {}
}

contract MockFactory {
    address public pair;

    function setPair(address _pair) public {
        pair = _pair;
    }

    function createPair(address, address) external returns (address) {
        return pair;
    }
}

contract JujutsuInuFeeTest is Test {
    JujutsuInu token;
    MockRouter router;
    address weth;
    address factory;
    address owner = address(this);
    address pair;
    address user = address(0x1001);
    uint8 internal constant DECIMALS = 9;

    function setUp() public {
        pair = address(0xdeaf);

        // Create mock contracts
        weth = address(new MockWETH());
        factory = address(new MockFactory());
        MockFactory(factory).setPair(pair);
        router = new MockRouter(factory, weth);

        // Deploy token
        token = new JujutsuInu(address(router));
        
        // Transfer initial tokens to user (100 tokens)
        uint256 userAmount = 100 * 10**DECIMALS;
        token.transfer(user, userAmount);
    }

    function testHighSellFeePreventsTransfer() public {
        // Launch token by transferring 1 token to pair
        token.transfer(pair, 1 * 10**DECIMALS);
        // Advance blocks to pass launch period
        vm.roll(block.number + 10);

        uint256 sellAmount = 50 * 10**DECIMALS;

        console.log("--- BEFORE-Trigger Balance State ---");
        uint256 userBalanceBefore = token.balanceOf(user);
        uint256 pairBalanceBefore = token.balanceOf(pair);
        uint256 contractBalanceBefore = token.balanceOf(address(token));
        console.log("User Balance      :", userBalanceBefore);
        console.log("Pair Balance      :", pairBalanceBefore);
        console.log("Contract Balance  :", contractBalanceBefore);

        console.log("--- Trigger ChangeFee & Transfer ---");
        // Set 99% sell fee - maximum allowed percentage
        token.setFees(0, 99, 100);
        // Execute sale from user to pair
        vm.prank(user);
        token.transfer(pair, sellAmount);

        console.log("--- AFTER-Trigger Balance State ---");
        uint256 userBalanceAfter = token.balanceOf(user);
        uint256 pairBalanceAfter = token.balanceOf(pair);
        uint256 contractBalanceAfter = token.balanceOf(address(token));
        console.log("User Balance      :", userBalanceAfter);
        console.log("Pair Balance      :", pairBalanceAfter);
        console.log("Contract Balance  :", contractBalanceAfter);

        // Calculate balance changes
        uint256 userDiff = userBalanceBefore - userBalanceAfter;
        uint256 pairDiff = pairBalanceAfter - pairBalanceBefore;
        uint256 contractDiff = contractBalanceAfter - contractBalanceBefore;

        console.log("--- Balance Changes ---");
        console.log("User tokens lost   :", userDiff);
        console.log("Pair tokens gained :", pairDiff);
        console.log("Contract fees      :", contractDiff);

        // Expected fee and transfer calculations
        uint256 expectedFee = (sellAmount * 99) / 100;
        uint256 expectedToPair = sellAmount - expectedFee;

        // Vulnerability condition: 99% fee applied correctly
        bool vulnExists = (userDiff == sellAmount) &&
                          (pairDiff == expectedToPair) &&
                          (contractDiff == expectedFee);

        // Final vulnerability verdict
        if (vulnExists) {
            console.log("Vulnerability Exists: The high 99%% fee was successfully applied to the transfer, causing contract to collect abnormally high fees");
        } else {
            console.log("Vulnerability not Exist: The fee manipulation did not produce the expected balance changes");
        }
    }
}