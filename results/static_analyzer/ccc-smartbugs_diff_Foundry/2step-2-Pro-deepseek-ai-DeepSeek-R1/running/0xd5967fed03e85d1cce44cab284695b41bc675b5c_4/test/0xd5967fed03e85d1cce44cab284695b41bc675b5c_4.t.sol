// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

contract RevertingToken {
    function transferFrom(address, address, uint256) external pure {
        revert("Token transfer always fails");
    }
}

contract DemoTransferTest is Test {
    demo public demoContract;
    RevertingToken public revertingToken;
    address deployer = address(0x1);
    address from = address(0x2);
    address to = address(0x3);

    function setUp() public {
        vm.startPrank(deployer);
        demoContract = new demo();
        revertingToken = new RevertingToken();
        vm.stopPrank();
    }

    function test_stateUpdatedOnFailedTokenCall() public {
        address[] memory recipients = new address[](1);
        recipients[0] = to;
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialTotalTransfers = demoContract.totalTransfers(to);
        uint256 initialUserTransfers = demoContract.userTransfers(from, to);
        console.log("totalTransfers before:", initialTotalTransfers);
        console.log("userTransfers before:", initialUserTransfers);

        console.log("--- Trigger Transfer Call (will fail) ---");
        vm.startPrank(deployer);
        demoContract.transfer(
            from,
            address(revertingToken),
            recipients,
            100
        );
        vm.stopPrank();

        console.log("--- AFTER-Trigger State ---");
        uint256 updatedTotalTransfers = demoContract.totalTransfers(to);
        uint256 updatedUserTransfers = demoContract.userTransfers(from, to);
        console.log("totalTransfers after:", updatedTotalTransfers);
        console.log("userTransfers after:", updatedUserTransfers);

        bool stateChanged = (updatedTotalTransfers != initialTotalTransfers) || 
                           (updatedUserTransfers != initialUserTransfers);
        
        console.log("Comparison:"); 
        console.log("State changed:", stateChanged);
        console.log("Vulnerability status:", 
                    stateChanged ? "State updated despite transfer failure" : 
                                    "State unchanged when transfer failed");
                    
        if(stateChanged) {
            console.log("Vulnerability Exists: contract state was improperly updated despite failed token transfer");
        } else {
            console.log("Vulnerability not Exist: state remains unchanged on token transfer failure as expected");
        }
    }
}