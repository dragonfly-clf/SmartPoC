// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KazamaSenshi.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x7000000000000000000000000000000000000000);
    }
    
    function WETH() external pure returns (address) {
        return address(0xC000000000000000000000000000000000000000);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x7000000000000000000000000000000000000001);
    }
}

contract TransferOwnershipTest is Test {
    KazamaSenshi token;
    address deployer = address(0x1);
    address newOwner = address(0x2);
    address zeroAddress = address(0);

    function setUp() public {
        // Deploy mock contracts
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();

        // Define valid address targets for mock setup
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address factoryAddress = 0x7000000000000000000000000000000000000000;
        
        // Apply mock contracts to target addresses
        vm.etch(routerAddress, address(mockRouter).code);
        vm.etch(factoryAddress, address(mockFactory).code);

        // Deploy token with necessary mocks in place
        vm.startPrank(deployer);
        token = new KazamaSenshi();
        vm.stopPrank();
    }

    function test_TransferToZeroAddressReverts() public {
        vm.startPrank(deployer);
        
        console.log("--- BEFORE-Trigger TransferOwnership ---");
        address ownerBefore = token.owner();
        console.log("Current owner:", ownerBefore);
        
        console.log("--- Trigger TransferOwnership(zeroAddress) ---");
        vm.expectRevert("Zaibatsu: No zero ..");
        token.transferOwnership(zeroAddress);
        
        console.log("--- AFTER-Trigger TransferOwnership ---");
        address ownerAfter = token.owner();
        console.log("Current owner:", ownerAfter);
        
        bool ownerUnchanged = (ownerBefore == ownerAfter);
        console.log("Owner unchanged:", ownerUnchanged ? "YES" : "NO");
        
        if (ownerUnchanged) {
            console.log("Vulnerability not Exist: Transfer to zero address properly reverted");
        } else {
            console.log("Vulnerability Exists: Ownership changed after invalid transfer");
        }
        
        assertEq(ownerAfter, deployer, "Ownership changed to zero address");
        vm.stopPrank();
    }
    
    function test_ValidOwnershipTransfer() public {
        vm.startPrank(deployer);
        
        console.log("--- BEFORE-Trigger TransferOwnership ---");
        address ownerBefore = token.owner();
        console.log("Current owner:", ownerBefore);
        assertEq(ownerBefore, deployer);
        
        console.log("--- Trigger TransferOwnership(newOwner) ---");
        token.transferOwnership(newOwner);
        
        console.log("--- AFTER-Trigger TransferOwnership ---");
        address ownerAfter = token.owner();
        console.log("Current owner:", ownerAfter);
        
        bool ownerChanged = (ownerBefore != ownerAfter);
        console.log("Owner changed:", ownerChanged ? "YES" : "NO");
        
        if (ownerChanged) {
            console.log("Vulnerability not Exist: Valid ownership transfer executed successfully");
        } else {
            console.log("Vulnerability Exists: Ownership did not change after valid transfer");
        }
        
        assertEq(token.owner(), newOwner, "Ownership transfer failed");
        vm.stopPrank();
    }
}