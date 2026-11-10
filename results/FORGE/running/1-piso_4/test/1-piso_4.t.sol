// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PISO.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xabc);
    }
}

contract MockWETH {}

contract MockRouter {
    address public immutable factory;
    address public immutable weth;

    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }

    function WETH() external view returns (address) {
        return weth;
    }
}

contract BlacklistTest is Test {
    PISO token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address carol = makeAddr("carol");

    function setUp() public {
        // Deploy required mock contracts
        MockWETH weth = new MockWETH();
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory), address(weth));

        vm.startPrank(owner);
        token = new PISO(address(router));
        token.setTradingStatus(true); // Enable trading
        token.updateCooldown(false, 0); // Disable cooldown
        token.setTaxes(0, 0, 0, 0, 0); // Remove taxes
        token.setSellTaxes(0, 0, 0, 0, 0); // Remove sell taxes
        vm.stopPrank();

        // Transfer 1 ether to Alice - within total supply limits
        vm.prank(owner);
        token.transfer(alice, 1 ether);
    }

    function _attemptTransfer(address from, address to, uint256 amount) internal returns (bool ok) {
        vm.prank(from);
        try token.transfer(to, amount) returns (bool success) {
            ok = success;
        } catch {
            ok = false;
        }
    }

    function testBlacklistVulnerability() public {
        uint256 probeAmount = 0.1 ether;

        console.log("--- BEFORE-Trigger State Snapshot ---");
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 bobBalanceBefore = token.balanceOf(bob);
        console.log("Alice balance before pre-transfer:", aliceBalanceBefore);
        console.log("Bob balance before pre-transfer:", bobBalanceBefore);

        bool preTransferSuccess = _attemptTransfer(alice, bob, probeAmount);
        console.log("Pre-trigger Alice->Bob transfer success:", preTransferSuccess ? "true" : "false");

        uint256 aliceBalanceAfterPre = token.balanceOf(alice);
        uint256 bobBalanceAfterPre = token.balanceOf(bob);
        console.log("Alice balance after pre-transfer:", aliceBalanceAfterPre);
        console.log("Bob balance after pre-transfer:", bobBalanceAfterPre);
        console.log("Pre-transfer Alice balance delta:", aliceBalanceBefore - aliceBalanceAfterPre);
        console.log("Pre-transfer Bob balance delta:", bobBalanceAfterPre - bobBalanceBefore);

        console.log("--- Trigger: Owner blacklists Alice ---");
        vm.prank(owner);
        token.updateIsBCheck(alice, true);

        console.log("--- AFTER-Trigger State Snapshot ---");
        uint256 aliceBalanceBeforePost = token.balanceOf(alice);
        uint256 bobBalanceBeforePost = token.balanceOf(bob);
        console.log("Alice balance before post-transfer:", aliceBalanceBeforePost);
        console.log("Bob balance before post-transfer:", bobBalanceBeforePost);

        bool postTransferSuccess = _attemptTransfer(alice, bob, probeAmount);
        console.log("Post-trigger Alice->Bob transfer success:", postTransferSuccess ? "true" : "false");

        uint256 aliceBalanceAfterPost = token.balanceOf(alice);
        uint256 bobBalanceAfterPost = token.balanceOf(bob);
        console.log("Alice balance after post-transfer:", aliceBalanceAfterPost);
        console.log("Bob balance after post-transfer:", bobBalanceAfterPost);
        console.log("Post-transfer Alice balance delta:", aliceBalanceBeforePost - aliceBalanceAfterPost);
        console.log("Post-transfer Bob balance delta:", bobBalanceAfterPost - bobBalanceBeforePost);

        bool statusChanged = preTransferSuccess != postTransferSuccess;
        bool exploitConfirmed = preTransferSuccess && !postTransferSuccess;

        console.log("Comparison verdict: transfer success status changed:", statusChanged ? "YES" : "NO");
        console.log("Comparison verdict: exploitation succeeded:", exploitConfirmed ? "YES" : "NO");

        // Continue original batch blacklist test as an additional differential check
        console.log("--- BEFORE-Batch-Blacklist Bob State Snapshot ---");
        uint256 bobBalanceBeforeBatch = token.balanceOf(bob);
        console.log("Bob balance before batch probe:", bobBalanceBeforeBatch);

        bool bobBeforeBatch = _attemptTransfer(bob, carol, 0.05 ether);
        console.log("Bob->Carol transfer success before batch blacklist:", bobBeforeBatch ? "true" : "false");

        address[] memory accounts = new address[](2);
        accounts[0] = alice;
        accounts[1] = bob;

        console.log("--- Trigger: Owner batch blacklists Alice and Bob ---");
        vm.prank(owner);
        token.BCheck(accounts, true);

        console.log("--- AFTER-Batch-Blacklist Bob State Snapshot ---");
        uint256 bobBalanceBeforeBatchPost = token.balanceOf(bob);
        console.log("Bob balance before batch post-probe:", bobBalanceBeforeBatchPost);

        bool bobAfterBatch = _attemptTransfer(bob, carol, 0.05 ether);
        console.log("Bob->Carol transfer success after batch blacklist:", bobAfterBatch ? "true" : "false");

        uint256 bobBalanceAfterBatchPost = token.balanceOf(bob);
        console.log("Bob balance after batch post-probe:", bobBalanceAfterBatchPost);

        bool batchStatusChanged = bobBeforeBatch != bobAfterBatch;
        bool batchExploit = bobBeforeBatch && !bobAfterBatch;
        exploitConfirmed = exploitConfirmed || batchExploit;

        console.log("Batch comparison verdict: transfer success status changed:", batchStatusChanged ? "YES" : "NO");
        console.log("Batch comparison verdict: exploitation succeeded:", batchExploit ? "YES" : "NO");

        if (exploitConfirmed) {
            console.log("Vulnerability Exists: Blacklisting changed transfer success status from true to false");
        } else {
            console.log("Vulnerability not Exist: Blacklisting did not change transfer success status from true to false");
        }
    }
}