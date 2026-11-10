// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LEP.sol";

// ---------------------------------------------------------------------------
// Mock contracts used only to satisfy the LEP constructor's external calls
// (factory(), WETH(), createPair(), token0()/token1(), getReserves()).
// ---------------------------------------------------------------------------
contract MockPair {
    address public token0;
    address public token1;

    constructor(address _token0, address _token1) public {
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() external pure returns (uint112, uint112, uint32) {
        return (0, 0, 0);
    }

    function sync() external {}
}

contract MockFactory {
    // Deploys a real pair mock so token0/token1 reflect the requested tokens.
    function createPair(address tokenA, address tokenB) external returns (address) {
        return address(new MockPair(tokenA, tokenB));
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xFAC70);
    }

    function WETH() external pure returns (address) {
        return address(0xBEEF1);
    }

    // Swallow any unexpected call so the constructor never reverts on it.
    fallback() external payable {}
}

contract BlacklistHoneypotTest is Test {
    LEP token;
    address owner = address(this); // Test contract is owner/deployer
    address alice = address(0x10);
    address bob = address(0x11);

    // The hardcoded addresses the LEP constructor expects.
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FAKE_FACTORY = address(0xFAC70);
    address constant FAKE_WETH = address(0xBEEF1);

    // Returns the runtime bytecode at `target` (works pre-0.8, no `.code`).
    function _runtimeCode(address target) internal view returns (bytes memory) {
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        bytes memory code = new bytes(size);
        assembly {
            extcodecopy(target, add(code, 0x20), 0, size)
        }
        return code;
    }

    function setUp() public {
        // Deploy mocks, then place their bytecode at the addresses the
        // LEP constructor hardcodes, so `new LEP()` does not revert.
        MockRouter routerMock = new MockRouter();
        MockFactory factoryMock = new MockFactory();

        vm.etch(ROUTER, _runtimeCode(address(routerMock)));
        vm.etch(FAKE_FACTORY, _runtimeCode(address(factoryMock)));
        vm.etch(FAKE_WETH, _runtimeCode(address(routerMock)));

        token = new LEP(); // Deploy token contract
        vm.deal(owner, 100 ether);
    }

    function testUserBlacklistedDuringVulnerableWindow() public {
        // Enable trading and set a long vulnerability window.
        token.setopenBool(true);
        token.setLunchTime(1000);

        uint256 transferAmount = 1000 * (10 ** uint256(token.decimals()));

        // ---------------------------------------------------------------
        // (i) BEFORE trigger: identical state snapshot
        // ---------------------------------------------------------------
        bool isbookBefore = token.isbook(alice);
        uint256 aliceBalanceBefore = token.balanceOf(alice);

        console.log("--- BEFORE: pre-trigger state snapshot ---");
        console.log("Alice isbook before:", isbookBefore);
        console.log("Alice balance before:", aliceBalanceBefore);

        // ---------------------------------------------------------------
        // (ii) TRIGGER operation: owner transfers to Alice in the window
        // ---------------------------------------------------------------
        console.log("--- TRIGGER: token.transfer(alice, transferAmount) in vulnerable window ---");
        token.transfer(alice, transferAmount);

        // ---------------------------------------------------------------
        // (iii) AFTER trigger: identical state snapshot
        // ---------------------------------------------------------------
        bool isbookAfter = token.isbook(alice);
        uint256 aliceBalanceAfter = token.balanceOf(alice);

        console.log("--- AFTER: post-trigger state snapshot ---");
        console.log("Alice isbook after:", isbookAfter);
        console.log("Alice balance after:", aliceBalanceAfter);

        // Attempt Alice's outgoing transfer; if blacklisted it must revert.
        uint256 transferThreshold = aliceBalanceAfter / 1000 + 1; // > 0.1% threshold
        vm.prank(alice);
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", bob, transferThreshold)
        );
        console.log("--- POST-TRIGGER: Alice outgoing transfer attempt ---");
        console.log("Alice outgoing transfer success:", success);

        // ---------------------------------------------------------------
        // (iv) Comparison verdict
        // ---------------------------------------------------------------
        bool blacklistStateChanged = (isbookBefore != isbookAfter);
        bool becameBlacklisted = (!isbookBefore && isbookAfter);
        bool exploitSucceeded = blacklistStateChanged && becameBlacklisted && !success;

        console.log("Blacklist state changed:", blacklistStateChanged);
        console.log("Alice became blacklisted (false -> true):", becameBlacklisted);

        if (exploitSucceeded) {
            console.log(
                "Vulnerability Exists: Alice was blacklisted after receiving tokens in the vulnerable window and her outgoing transfer reverted"
            );
        } else {
            console.log(
                "Vulnerability not Exist: Alice blacklist state did not change from false to true, or her outgoing transfer did not revert"
            );
        }
    }
}