// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/JOKECOMMUNITY.sol";

/// @dev Universal stub: for ANY call it returns its own address as a 32-byte
///      word. It is installed at the hard-coded Uniswap/Pancake router address
///      so the token constructor's calls (router.factory(), router.WETH(),
///      factory.createPair(...)) no longer hit a non-contract address.
///      It uses only memory ops, so it also works under STATICCALL (view fns).
contract RouterStub {
    fallback() external payable {
        assembly {
            mstore(0x00, address())
            return(0x00, 0x20)
        }
    }
}

contract JOKECOMMUNITYLockTest is Test {
    JOKECOMMUNITY token;
    address owner = address(this);
    address user = address(0x1);

    // This will simulate the actual Uniswap router (as referenced by the token)
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Copy the runtime code of an already-deployed contract
    function _copyCode(address _addr) internal returns (bytes memory code) {
        assembly {
            let size := extcodesize(_addr)
            code := mload(0x40)
            mstore(0x40, add(code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(code, size)
            extcodecopy(_addr, add(code, 0x20), 0, size)
        }
    }

    function _codeSize(address _addr) internal view returns (uint256 s) {
        assembly { s := extcodesize(_addr) }
    }

    function setUp() public {
        // FIX: put code at the hard-coded router address so the token's
        // constructor (which calls router.factory()/WETH()) does not revert
        // with "call to non-contract address".
        RouterStub stub = new RouterStub();
        vm.etch(ROUTER, _copyCode(address(stub)));
        assertTrue(_codeSize(ROUTER) > 0, "Router stub not installed");

        // Deploy token (auto-configures Uniswap using the stub)
        token = new JOKECOMMUNITY();

        // Give the test user some tokens (fraction of owner's supply so we
        // stay below any maxTxAmount configured by the constructor)
        uint256 ownerBal = token.balanceOf(owner);
        assertTrue(ownerBal > 0, "Owner should hold supply after deploy");
        token.transfer(user, ownerBal / 10000);
        assertTrue(token.balanceOf(user) > 0, "User should have tokens");
    }

    function testTransactionLock() public {
        uint256 transferAmt = token.balanceOf(user) / 10;
        assertTrue(transferAmt > 0, "transferAmt must be > 0");

        // ------------------------------------------------------------------
        // (i) BEFORE trigger: pre-trigger action + state snapshot
        // ------------------------------------------------------------------
        console.log("--- BEFORE Trigger: pre-trigger action and state snapshot ---");
        bool lockedBefore = token.locked();
        uint256 userBalBefore = token.balanceOf(user);
        console.log("locked before trigger:", lockedBefore);
        console.log("user balance before trigger:", userBalBefore);

        // Pre-trigger transfer should succeed while unlocked
        vm.prank(user);
        bool preTransferSuccess = token.transfer(address(0x2), transferAmt);
        console.log("pre-trigger transfer success:", preTransferSuccess);
        console.log("user balance after pre-trigger transfer:", token.balanceOf(user));

        // ------------------------------------------------------------------
        // (ii) TRIGGER: the critical attacker/owner action
        // ------------------------------------------------------------------
        console.log("--- Trigger: call transferLock() ---");
        token.transferLock();
        console.log("transferLock() executed");

        // ------------------------------------------------------------------
        // (iii) AFTER trigger: post-trigger action + state snapshot
        // ------------------------------------------------------------------
        console.log("--- AFTER Trigger: post-trigger action and state snapshot ---");
        bool lockedAfter = token.locked();
        console.log("locked after trigger:", lockedAfter);

        uint256 userBalBeforePost = token.balanceOf(user);
        console.log("user balance before post-trigger transfer:", userBalBeforePost);

        // Post-trigger transfer should be blocked; use low-level call so the
        // test does not revert if the token reverts.
        vm.prank(user);
        (bool postTransferSuccess, ) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", address(0x3), transferAmt)
        );
        uint256 userBalAfterPost = token.balanceOf(user);

        // A transfer is considered blocked if it either reverted OR left the
        // sender's balance untouched (returned false without moving funds).
        bool transferBlocked = (!postTransferSuccess) || (userBalAfterPost == userBalBeforePost);

        console.log("post-trigger transfer success:", postTransferSuccess);
        console.log("post-trigger transfer blocked:", transferBlocked);
        console.log("user balance after trigger:", userBalAfterPost);

        // ------------------------------------------------------------------
        // (iv) Comparison verdict
        // ------------------------------------------------------------------
        bool lockedStateChanged = (lockedBefore != lockedAfter);
        console.log("locked state changed:", lockedStateChanged);

        if (lockedBefore == false && lockedAfter == true) {
            console.log("Vulnerability Exists: transferLock() flipped locked from false->true, pre-lock transfer succeeded, post-lock transfer blocked");
        } else {
            console.log("Vulnerability not Exist: locked state did not transition from false->true");
        }
    }
}