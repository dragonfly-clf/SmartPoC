// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KingdomCoin.sol";

contract KingdomCoinBlacklistTest is Test {
    KingdomCoin token;
    address owner;
    
    function setUp() public {
        owner = address(this);
        // PancakeSwap router address - without constant modifier
        address PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = makeAddr("mock_factory");
        address mockPair = makeAddr("mock_pair");
        address mockWETH = makeAddr("mock_weth");
        
        // Mock router factory() and WETH() calls
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory createPair() call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        token = new KingdomCoin();
    }

    function test_BlacklistEmitsDuplicateEvents() public {
        address user1 = address(0x1);
        address user2 = address(0x2);
        address user3 = address(0x3);
        
        // Create array with duplicate address
        address[] memory users = new address[](4);
        users[0] = user1;
        users[1] = user2;
        users[2] = user1; // Duplicate entry
        users[3] = user3;

        console2.log("--- BEFORE-Trigger ---");
        console2.log("Users to blacklist:");
        console2.log("   user1:", user1);
        console2.log("   user2:", user2);
        console2.log("   user1 (duplicate):", user1);
        console2.log("   user3:", user3);

        console2.log("--- Trigger: token.blackList() ---");
        vm.recordLogs();
        token.blackList(users, true);

        Vm.Log[] memory logs = vm.getRecordedLogs();
        bytes32 blackListEventSig = keccak256("BlackList(address)");
        uint256 countForUser1;

        // Count events for user1
        for (uint256 i; i < logs.length; i++) {
            if (logs[i].topics[0] == blackListEventSig) {
                address emittedAddress = address(uint160(uint256(logs[i].topics[1])));
                if (emittedAddress == user1) countForUser1++;
            }
        }

        console2.log("--- AFTER-Trigger ---");
        console2.log("Blacklist events for user1:", countForUser1);
        
        // Vulnerability verification
        if (countForUser1 == 2) {
            console2.log("Vulnerability Exists: Duplicate events emitted for same address");
        } else {
            console2.log("Vulnerability not Exist: No duplicate events detected");
        }
    }
}