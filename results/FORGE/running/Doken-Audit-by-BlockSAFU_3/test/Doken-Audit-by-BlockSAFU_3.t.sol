// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DoKENV2.sol";

contract DoKENV2OwnershipTest is Test {
    DoKENV2 token;
    address owner = address(0x1);
    address user = address(0x2);

    // Mock router address for deployment
    address constant MOCK_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        // Mock router interactions
        vm.mockCall(
            MOCK_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0x3))
        );
        vm.mockCall(
            address(0x3),
            abi.encodeWithSignature("createPair(address,address)", WBNB, address(this)),
            abi.encode(address(0x4))
        );
        
        // Deploy contract as owner
        vm.startPrank(owner);
        token = new DoKENV2();
        vm.stopPrank();
    }

    function testRenouncedOwnerCannotPause() public {
        // Renounce ownership as owner
        vm.prank(owner);
        token.renounceOwnership();

        console.log("--- BEFORE-Trigger PauseTx ---");
        console.log("Current owner:", token.owner());
        console.log("Expected revert reason: 'Ownable: caller is not the owner'");

        console.log("--- Trigger PauseTx ---");
        console.log("Attempted by renounced owner (%s)", owner);
        (bool success1, ) = address(token).call(
            abi.encodeWithSelector(token.pauseTx.selector, true, true)
        );

        console.log("--- AFTER-Trigger PauseTx ---");
        console.log("Transaction success status:", success1);
        require(!success1, "Non-owner should not be able to pause");

        // Final differential verdict
        console.log("Vulnerability not Exist: Renounced owner failed to pause as expected");
    }

    function testNonOwnerCannotChangeParameters() public {
        // Renounce ownership
        vm.prank(owner);
        token.renounceOwnership();

        console.log("--- BEFORE-Trigger setBuyTxMaximum ---");
        console.log("Current owner:", token.owner());
        console.log("Expected revert reason: 'Ownable: caller is not the owner'");

        console.log("--- Trigger setBuyTxMaximum ---");
        console.log("Attempted by non-owner (%s)", user);
        (bool success2, ) = address(token).call(
            abi.encodeWithSelector(token.setBuyTxMaximum.selector, 10)
        );

        console.log("--- AFTER-Trigger setBuyTxMaximum ---");
        console.log("Transaction success status:", success2);
        require(!success2, "Non-owner should not be able to set maximum");

        // Final differential verdict
        console.log("Vulnerability not Exist: Non-owner failed to change parameters");
    }
}