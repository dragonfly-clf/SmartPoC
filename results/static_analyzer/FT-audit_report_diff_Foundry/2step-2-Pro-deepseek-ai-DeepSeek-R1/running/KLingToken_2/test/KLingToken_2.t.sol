// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KLingToken.sol";

contract FixedMockToken {
    mapping(address => uint256) public balanceOf;

    constructor(address sender) {
        balanceOf[sender] = 1000 ether;
    }
    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract KLingTokenOwnerPrivilegeTest is Test {
    KLingToken token;
    FixedMockToken mockToken;
    address owner = address(0x123);
    address receiver = address(0x456);

    function setUp() public {
        vm.startPrank(owner);
        token = new KLingToken(owner);
        vm.stopPrank();
        
        // Create mock token and fund test contract
        mockToken = new FixedMockToken(address(this));
        
        // Transfer to token contract - uses SafeTransfer now
        require(mockToken.balanceOf(address(this)) >= 500 ether, "Test contract lacks balance");
        mockToken.transfer(address(token), 500 ether);
        
        // Fund token contract with ETH
        vm.deal(address(token), 10 ether);
    }

    function test_owner_can_drain_ether_via_adminEmergency() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 initialContractBalance = address(token).balance;
        uint256 initialReceiverBalance = receiver.balance;
        console.log("Contract ETH balance:", initialContractBalance);
        console.log("Receiver ETH balance:", initialReceiverBalance);

        console.log("--- Trigger adminEmergency for ETH ---");
        vm.prank(owner);
        token.adminEmergency(address(0), receiver, initialContractBalance);

        console.log("--- AFTER-Trigger ---");
        uint256 finalContractBalance = address(token).balance;
        uint256 finalReceiverBalance = receiver.balance;
        console.log("Contract ETH balance:", finalContractBalance);
        console.log("Receiver ETH balance:", finalReceiverBalance);

        bool vulnerabilityExists = (finalContractBalance == 0) && 
                                   (finalReceiverBalance == initialReceiverBalance + initialContractBalance);

        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can drain contract ETH via adminEmergency");
        } else {
            console.log("Vulnerability not Exist: Contract ETH not drained");
            fail("Vulnerability not Exist: Contract ETH not drained");
        }
    }

    function test_owner_can_drain_tokens_via_adminEmergency() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 initialContractTokenBalance = mockToken.balanceOf(address(token));
        uint256 initialReceiverTokenBalance = mockToken.balanceOf(receiver);
        console.log("Contract token balance:", initialContractTokenBalance);
        console.log("Receiver token balance:", initialReceiverTokenBalance);

        console.log("--- Trigger adminEmergency for Token ---");
        vm.prank(owner);
        token.adminEmergency(address(mockToken), receiver, initialContractTokenBalance);

        console.log("--- AFTER-Trigger ---");
        uint256 finalContractTokenBalance = mockToken.balanceOf(address(token));
        uint256 finalReceiverTokenBalance = mockToken.balanceOf(receiver);
        console.log("Contract token balance:", finalContractTokenBalance);
        console.log("Receiver token balance:", finalReceiverTokenBalance);

        bool vulnerabilityExists = (finalContractTokenBalance == 0) && 
                                   (finalReceiverTokenBalance == initialReceiverTokenBalance + initialContractTokenBalance);

        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Owner can drain contract tokens via adminEmergency");
        } else {
            console.log("Vulnerability not Exist: Contract tokens not drained");
            fail("Vulnerability not Exist: Contract tokens not drained");
        }
    }
}