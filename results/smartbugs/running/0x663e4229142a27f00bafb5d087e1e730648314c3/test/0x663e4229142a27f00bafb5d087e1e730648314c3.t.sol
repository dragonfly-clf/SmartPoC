// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x663e4229142a27f00bafb5d087e1e730648314c3.sol";

contract Rejector {
    fallback() external payable {
        revert();
    }
}

contract UncheckedCallTest is Test {
    PandaCore pandaCore;
    Rejector rejector;
    address owner = address(0x123);
    address nftContract;

    function setUp() public {
        // Deploy PandaCore contract
        vm.prank(owner);
        pandaCore = new PandaCore();
        
        // Deploy rejector contract
        rejector = new Rejector();
        nftContract = address(rejector);
        
        // Set NFT contract address to rejector using storage manipulation
        bytes32 slot = bytes32(uint256(3)); // nonFungibleContract storage slot
        vm.store(address(pandaCore), slot, bytes32(uint256(uint160(nftContract))));
        
        // Fund the contract with Ether
        vm.deal(address(pandaCore), 1 ether);
    }

    function testUncheckedTransferFailure() public {
        console2.log("--- BEFORE-Trigger State ---");
        uint256 pandaBalanceBefore = address(pandaCore).balance;
        uint256 nftBalanceBefore = address(nftContract).balance;
        console2.log("PandaCore balance before:", pandaBalanceBefore);
        console2.log("NFTContract balance before:", nftBalanceBefore);

        console2.log("--- Trigger Operation: withdrawBalance() ---");
        bool success;
        vm.prank(owner);
        (success, ) = address(pandaCore).call(abi.encodeWithSignature("withdrawBalance()"));
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 pandaBalanceAfter = address(pandaCore).balance;
        uint256 nftBalanceAfter = address(nftContract).balance;
        console2.log("Call success status:", success);
        console2.log("PandaCore balance after:", pandaBalanceAfter);
        console2.log("NFTContract balance after:", nftBalanceAfter);
        
        if (success) {
            console2.log("Vulnerability Exist: withdrawBalance executed without revert on failed transfer");
        } else {
            console2.log("Vulnerability not Exist: withdrawBalance reverted as expected");
        }
    }
}