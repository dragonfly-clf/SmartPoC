// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MANU.sol";

// Minimal mock of the PancakeSwap V2 Router.
// - factory() returns address(this) so that when the MANU constructor does
//   IUniswapV2Factory(_router.factory()).createPair(...) the call routes back
//   to this same mocked contract (which implements createPair).
// - createPair() returns address(this) so uniswapV2Pair is a valid contract.
// - swap/liquidity stubs prevent reverts if the token tries to swap fees.
contract MockRouter {
    function factory() external view returns (address) { return address(this); }

    function WETH() external view returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }

    function createPair(address, address) external view returns (address) {
        return address(this);
    }

    function getPair(address, address) external view returns (address) {
        return address(this);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (0, 0, uint32(block.timestamp));
    }

    function token0() external view returns (address) { return address(this); }
    function token1() external view returns (address) { return address(this); }
    function sync() external {}

    function addLiquidity(
        address, address, uint256, uint256, uint256, uint256, address, uint256
    ) external returns (uint256, uint256, uint256) { return (0, 0, 0); }

    function addLiquidityETH(
        address, uint256, uint256, uint256, address, uint256
    ) external payable returns (uint256, uint256, uint256) { return (0, 0, 0); }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, uint256, address[] calldata, address, uint256
    ) external {}

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256, uint256, address[] calldata, address, uint256
    ) external {}

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256, address[] calldata, address, uint256
    ) external payable {}
}

contract MANUFeeDistributionTest is Test {
    MANU token;
    address owner = address(this);
    address alice = address(0x1);
    address bob = address(0x2);
    address charlie = address(0x3);
    address marketingAddr;

    // BSC PancakeSwap V2 Router referenced by MANU's constructor
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Grouped snapshot to avoid "stack too deep" on Solidity 0.6.12
    struct Snapshot {
        uint256 supply;
        uint256 marketing;
        uint256 contractBal;
        uint256 aliceBal;
        uint256 bobBal;
        uint256 charlieBal;
    }

    // Grouped deltas to avoid "stack too deep"
    struct Delta {
        uint256 supplyReduction;
        uint256 marketingIncrease;
        uint256 contractIncrease;
        uint256 aliceDecrease;
        uint256 bobIncrease;
        uint256 charlieIncrease;
        uint256 totalDistributed;
    }

    function _positiveDiff(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a - b : 0;
    }

    // Solidity 0.6.12 has no `address.code` member, so extract the runtime
    // bytecode of a deployed contract via inline assembly (extcodesize/extcodecopy).
    function _getCode(address _addr) internal view returns (bytes memory code) {
        assembly {
            let size := extcodesize(_addr)
            code := mload(0x40)
            mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(code, size)
            extcodecopy(_addr, add(code, 0x20), 0, size)
        }
    }

    function setUp() public {
        // ---- FIX: provide a working router at the hardcoded BSC address ----
        // Deploy the mock and copy its runtime code to the PancakeSwap router
        // address so the MANU constructor's external call does not revert with
        // "call to non-contract address".
        MockRouter mockRouter = new MockRouter();
        vm.etch(PANCAKE_ROUTER, _getCode(address(mockRouter)));

        // Deploy token (constructor now succeeds)
        token = new MANU();

        // Set test marketing address
        marketingAddr = address(0x4);
        // Note: Requires modification to marketing_address visibility for testing
        vm.store(
            address(token),
            bytes32(uint256(keccak256("MANU.marketing_address"))),
            bytes32(uint256(uint160(marketingAddr)))
        );

        // Exclude owner from fee to avoid fees during setup
        token.excludeFromFee(owner);

        // Fund test accounts
        token.transfer(alice, 1000 ether);
        token.transfer(charlie, 500 ether);

        // Simulate adding addresses to system by performing transactions
        vm.prank(charlie);
        token.transfer(address(0x5), 1);
    }

    function _snapshot() internal view returns (Snapshot memory s) {
        s.supply = token.totalSupply();
        s.marketing = token.balanceOf(marketingAddr);
        s.contractBal = token.balanceOf(address(token));
        s.aliceBal = token.balanceOf(alice);
        s.bobBal = token.balanceOf(bob);
        s.charlieBal = token.balanceOf(charlie);
    }

    function _logSnapshot(Snapshot memory s) internal view {
        console.log("totalSupply:", s.supply);
        console.log("marketing balance:", s.marketing);
        console.log("contract balance:", s.contractBal);
        console.log("alice balance:", s.aliceBal);
        console.log("bob balance:", s.bobBal);
        console.log("charlie balance:", s.charlieBal);
    }

    function _computeDelta(Snapshot memory b, Snapshot memory a) internal pure returns (Delta memory d) {
        d.supplyReduction = _positiveDiff(b.supply, a.supply);
        d.marketingIncrease = _positiveDiff(a.marketing, b.marketing);
        d.contractIncrease = _positiveDiff(a.contractBal, b.contractBal);
        d.aliceDecrease = _positiveDiff(b.aliceBal, a.aliceBal);
        d.bobIncrease = _positiveDiff(a.bobBal, b.bobBal);
        d.charlieIncrease = _positiveDiff(a.charlieBal, b.charlieBal);
        d.totalDistributed = d.marketingIncrease + d.contractIncrease + d.charlieIncrease;
    }

    function testSupplyInconsistency() public {
        uint256 transferAmount = 100 ether;

        // (i) PRE-TRIGGER snapshot
        console.log("--- BEFORE-Trigger State Snapshot ---");
        Snapshot memory before = _snapshot();
        _logSnapshot(before);

        // (ii) TRIGGER: alice transfers 100 ether to bob (fee logic executes)
        console.log("--- Trigger Operation: alice transfers 100 ether to bob ---");
        vm.prank(alice);
        token.transfer(bob, transferAmount);

        // (iii) POST-TRIGGER snapshot (identical queries)
        console.log("--- AFTER-Trigger State Snapshot ---");
        Snapshot memory afterState = _snapshot();
        _logSnapshot(afterState);

        // (iv) COMPARISON VERDICT
        console.log("--- Comparison Verdict ---");
        Delta memory d = _computeDelta(before, afterState);

        console.log("totalSupply changed:", before.supply != afterState.supply);
        console.log("marketing balance changed:", before.marketing != afterState.marketing);
        console.log("contract balance changed:", before.contractBal != afterState.contractBal);
        console.log("alice balance changed:", before.aliceBal != afterState.aliceBal);
        console.log("bob balance changed:", before.bobBal != afterState.bobBal);
        console.log("charlie balance changed:", before.charlieBal != afterState.charlieBal);

        console.log("supplyReduction (burn):", d.supplyReduction);
        console.log("marketingIncrease:", d.marketingIncrease);
        console.log("contractIncrease:", d.contractIncrease);
        console.log("charlieIncrease:", d.charlieIncrease);
        console.log("aliceDecrease:", d.aliceDecrease);
        console.log("bobIncrease:", d.bobIncrease);
        console.log("totalDistributed (marketing + contract + charlie):", d.totalDistributed);

        // Vulnerability criterion: the amount distributed to marketing/contract/
        // charlie is larger than the total supply reduction (deflation), i.e. the
        // fee allocation is inconsistent with the burn, and charlie (reward
        // account) actually received tokens.
        bool distributionExceedsBurn = d.totalDistributed > d.supplyReduction;
        bool charlieReceivedReward = d.charlieIncrease > 0;
        bool vulnerability = distributionExceedsBurn && charlieReceivedReward;

        console.log("distribution exceeds supply reduction:", distributionExceedsBurn);
        console.log("charlie received reward:", charlieReceivedReward);
        console.log("state changed and exploitation succeeded:", vulnerability);

        // Exactly one final line
        if (vulnerability) {
            console.log("Vulnerability Exists: fee distribution to marketing/contract/charlie exceeds the totalSupply reduction while charlie receives rewards");
        } else {
            console.log("Vulnerability not Exist: fee distribution is consistent with totalSupply reduction and/or charlie receives no reward");
        }
    }
}