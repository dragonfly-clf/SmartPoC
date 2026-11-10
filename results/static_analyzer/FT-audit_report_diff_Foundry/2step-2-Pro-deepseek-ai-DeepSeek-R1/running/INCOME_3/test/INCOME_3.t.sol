// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/INCOME.sol";

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xabc);
    }
}

contract INCOMEOwnershipTest is Test {
    INCOME token;
    address deployer = address(0x1);
    address newOwner = address(0x2);
    address lostAddress = address(0xDEAD);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    function setUp() public {
        vm.startPrank(deployer);

        // Deploy and setup mock contracts
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), WETH_ADDRESS);
        
        // Simulate router address using vm.etch
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        token = new INCOME();
        
        vm.stopPrank();
    }

    function testOneStepOwnershipTransfer() public {
        console.log("--- BEFORE-Trigger Ownership ---");
        address ownerBefore = token.owner();
        console.log("Current owner (before):", ownerBefore);

        console.log("--- Trigger Ownership Transfer ---");
        // Deployer transfers ownership successfully
        vm.prank(deployer);
        token.transferOwnership(newOwner);
        
        console.log("--- AFTER-Trigger Ownership ---");
        address ownerAfter = token.owner();
        console.log("Current owner (after):", ownerAfter);
    
        // Differential comparison
        if (ownerBefore != ownerAfter) {
            console.log("VERDICT: Ownership changed - Vulnerability exists");
            console.log("Vulnerability Exists: Contract allows dangerous one-step ownership transfer");
        } else {
            console.log("VERDICT: Ownership unchanged - Vulnerability not exists");
            console.log("Vulnerability not Exist: Ownership transfer failed");
        }
        
        assertEq(ownerAfter, newOwner, "Ownership should be transferred");
        
        // Verify critical function can be called by new owner
        vm.prank(newOwner);
        token.setMarketingWallet(payable(address(0x123)));
    }
    
    function testDangerousOneStepTransfer() public {
        console.log("--- BEFORE-Trigger Ownership ---");
        address ownerBefore = token.owner();
        console.log("Current owner (before):", ownerBefore);

        console.log("--- Trigger Ownership Transfer ---");
        // Simulate transferring ownership to an inaccessible address
        vm.prank(deployer);
        token.transferOwnership(lostAddress);
        
        console.log("--- AFTER-Trigger Ownership ---");
        address ownerAfter = token.owner();
        console.log("Current owner (after):", ownerAfter);
    
        // Differential comparison
        if (ownerBefore != ownerAfter) {
            console.log("VERDICT: Ownership changed - Vulnerability exists");
            console.log("Vulnerability Exists: Ownership transfer to dead address succeeded");
        } else {
            console.log("VERDICT: Ownership unchanged - Vulnerability not exists");
            console.log("Vulnerability not Exist: Ownership transfer failed");
        }
        
        assertEq(ownerAfter, lostAddress, "Ownership transferred to inaccessible address");
        
        // Simulate attempting to recover after lost ownership
        vm.startPrank(deployer);
        
        // Fixed expected revert message
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMarketingWallet(payable(address(0x456)));
        
        // Try to pause contract (should fail - no such function exists)
        bytes memory payload = abi.encodeWithSignature("pause()");
        (bool success, ) = address(token).call(payload);
        assertTrue(!success, "Pause function shouldn't exist");
        
        vm.stopPrank();
    }
}