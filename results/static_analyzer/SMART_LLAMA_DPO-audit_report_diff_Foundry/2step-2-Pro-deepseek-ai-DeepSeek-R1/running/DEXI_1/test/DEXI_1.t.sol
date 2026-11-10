// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract DEXIZeroAddressTest is Test {
    DEXI private token;
    address private owner;
    address private user;
    address private constant ZERO_ADDRESS = address(0);

    function setUp() public {
        owner = address(this);
        user = address(2);
        
        token = new DEXI(); // Total supply minted to owner (this contract) in constructor
        
        // Configuration
        token.excludeFromFee(owner);
        token.excludeFromFee(user);
        token._setMaxTxAmount(type(uint256).max);
        
        // Transfer test tokens to user
        uint256 decimals = token.decimals();
        uint256 factor = 10 ** uint256(decimals);
        uint256 userAmount = 1000 * factor;
        token.transfer(user, userAmount);
    }

    // Combined test for both direct transfer and transferFrom to zero address
    function testVulnerability() public {
        uint256 decimals = token.decimals();
        uint256 factor = 10 ** uint256(decimals);
        uint256 directAmount = 500 * factor;
        uint256 transferFromAmount = 500 * factor;
        bool vulnerabilityExists = false;

        // Test direct transfer to zero address
        console.log("--- Test Direct Transfer to Zero Address ---");
        vm.prank(user);
        try token.transfer(ZERO_ADDRESS, directAmount) {
            console.log("Direct transfer to zero address succeeded.");
            vulnerabilityExists = true;
        } catch (bytes memory) {
            console.log("Direct transfer to zero address reverted as expected.");
        }

        // Test transferFrom to zero address
        console.log("--- Test TransferFrom to Zero Address ---");
        vm.prank(user);
        token.approve(owner, transferFromAmount);

        vm.prank(owner);
        try token.transferFrom(user, ZERO_ADDRESS, transferFromAmount) {
            console.log("TransferFrom to zero address succeeded.");
            vulnerabilityExists = true;
        } catch (bytes memory) {
            console.log("TransferFrom to zero address reverted as expected.");
        }

        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: The contract allows transfers to the zero address.");
        } else {
            console.log("Vulnerability not Exist: The contract correctly blocks transfers to the zero address.");
        }
    }
}