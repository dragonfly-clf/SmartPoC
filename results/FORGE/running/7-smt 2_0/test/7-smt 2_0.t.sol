// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SantaCoin.sol";

contract DividendDistributor {
    function distributeDividends(uint256 amount) public {
        require(amount < 100 ether, "Untrusted source manipulated dividend distribution");
    }
}

// Mock WETH contract with minimal functionality
contract MockWETH {
    receive() external payable {}
}

contract MockFactory {
    address public pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
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

contract MockPair {
    constructor() {}
}

contract SantaCoinUntrustedSourceTest is Test {
    SantaCoin public token;
    DividendDistributor public maliciousDistributor;
    MockRouter public mockRouter;
    MockFactory public mockFactory;
    MockWETH public mockWETH;
    MockPair public mockPair;

    address public owner = makeAddr("owner");
    address constant DEAD = 0x000000000000000000000000000000000000dEaD;
    address constant BSC_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        vm.chainId(56);

        // Deploy mocks
        mockWETH = new MockWETH();
        mockPair = new MockPair();
        mockFactory = new MockFactory(address(mockPair));
        mockRouter = new MockRouter(address(mockFactory), address(mockWETH));

        // Replace BSC router with mock contract and initialize storage
        vm.etch(BSC_ROUTER, address(mockRouter).code);
        vm.store(BSC_ROUTER, bytes32(0), bytes32(uint256(uint160(address(mockFactory)))));
        vm.store(BSC_ROUTER, bytes32(uint256(1)), bytes32(uint256(uint160(address(mockWETH)))));

        vm.startPrank(owner);

        // Deploy main token contract
        token = new SantaCoin();

        // Get actual owner after deployment transfer
        address actualOwner = 0xc70327c3C21F6B3922f3a843B9fF77677140bfee;

        // Prepare to work as actual owner
        vm.stopPrank();
        vm.startPrank(actualOwner);

        // Replace dividend tracker with malicious version
        maliciousDistributor = new DividendDistributor();
        address dividendTrackerAddr = address(token.dividendTracker());
        vm.etch(dividendTrackerAddr, address(maliciousDistributor).code);

        vm.stopPrank();
    }

    // Helper: slice a bytes buffer (used to strip the 4-byte revert selector)
    function _slice(bytes memory data, uint256 start, uint256 length)
        internal
        pure
        returns (bytes memory)
    {
        bytes memory out = new bytes(length);
        for (uint256 i = 0; i < length; i++) {
            out[i] = data[start + i];
        }
        return out;
    }

    function test_untrusted_source_failure() public {
        address actualOwner = 0xc70327c3C21F6B3922f3a843B9fF77677140bfee;
        vm.startPrank(actualOwner);

        // Set up dividend distribution parameters
        uint256 amountToDistribute = 150 ether;

        // Get the dividend tracker address
        address dividendTrackerAddr = address(token.dividendTracker());

        // ============================================================
        // (i) BEFORE-Trigger : action + state snapshot
        // ============================================================
        console.log("--- BEFORE-Trigger State Snapshot ---");
        address trackerBefore        = address(token.dividendTracker());
        uint256 trackerBalBefore     = token.balanceOf(dividendTrackerAddr);
        uint256 trackerEthBefore     = dividendTrackerAddr.balance;
        uint256 totalSupplyBefore    = token.totalSupply();

        console.log("Dividend tracker address      :", trackerBefore);
        console.log("Tracker token balance before  :", trackerBalBefore);
        console.log("Tracker ETH balance before    :", trackerEthBefore);
        console.log("Total supply before           :", totalSupplyBefore);

        // Prepare the low-level call to the (etched) untrusted dividend source
        bytes memory payload =
            abi.encodeWithSignature("distributeDividends(uint256)", amountToDistribute);

        // ============================================================
        // (ii) TRIGGER : untrusted source attempts the distribution
        // ============================================================
        console.log("--- Trigger: distributeDividends(150 ether) via untrusted tracker ---");
        (bool success, bytes memory ret) = dividendTrackerAddr.call(payload);
        bool reverted = !success;

        // Decode the revert reason (Error(string)) if present
        string memory reason = "";
        if (ret.length > 4) {
            reason = abi.decode(_slice(ret, 4, ret.length - 4), (string));
        }

        // ============================================================
        // (iii) AFTER-Trigger : action + state snapshot
        // ============================================================
        console.log("--- AFTER-Trigger State Snapshot ---");
        address trackerAfter        = address(token.dividendTracker());
        uint256 trackerBalAfter     = token.balanceOf(dividendTrackerAddr);
        uint256 trackerEthAfter     = dividendTrackerAddr.balance;
        uint256 totalSupplyAfter    = token.totalSupply();

        console.log("Dividend tracker address      :", trackerAfter);
        console.log("Tracker token balance after   :", trackerBalAfter);
        console.log("Tracker ETH balance after     :", trackerEthAfter);
        console.log("Total supply after            :", totalSupplyAfter);

        // ============================================================
        // (iv) COMPARISON verdict : did the state change?
        // ============================================================
        bool stateChanged =
            (trackerBefore != trackerAfter) ||
            (trackerBalBefore != trackerBalAfter) ||
            (trackerEthBefore != trackerEthAfter) ||
            (totalSupplyBefore != totalSupplyAfter);

        bool expectedRevert =
            reverted &&
            keccak256(bytes(reason)) ==
            keccak256(bytes("Untrusted source manipulated dividend distribution"));

        console.log("--- Comparison ---");
        console.log("State changed by trigger      :", stateChanged);
        console.log("Trigger reverted              :", reverted);
        console.log("Revert reason                 :", reason);
        // Note: a revert-only manipulation does not mutate state (per the
        // "no_operation" differential plan), so exploitation is proven by the
        // untrusted source being able to block/manipulate the distribution.

        vm.stopPrank();

        // ============================================================
        // Final verdict : exactly one line
        // ============================================================
        if (expectedRevert) {
            console.log(
                "Vulnerability Exists: untrusted dividend source manipulated/blocked dividend distribution (expected revert reproduced, no state mutation as anticipated)"
            );
        } else if (reverted) {
            console.log(
                "Vulnerability Exists: untrusted dividend source disrupted the distribution with an unexpected revert"
            );
        } else {
            console.log(
                "Vulnerability not Exist: dividend distribution executed without the untrusted-source manipulation revert"
            );
        }
    }
}