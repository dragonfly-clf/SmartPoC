// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ELONPETS.sol";

contract MockToken {
    function balanceOf(address) public pure returns (uint256) {
        return 0;
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address pair) {
        return address(0xBEEF);
    }
}

contract ElonPetsOwnershipTest is Test {
    ELONPETS public token;
    address public owner = address(0x1);
    address public zeroAddress = address(0);
    address public constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create mock router dependencies
        address mockFactory = address(new MockFactory());
        address mockWeth = address(new MockToken());
        
        // Deploy mock router at predefined address
        vm.etch(ROUTER_ADDRESS, address(new MockRouter(mockFactory, mockWeth)).code);
        
        // Deploy the token contract
        vm.prank(owner);
        token = new ELONPETS();
    }

    function testTransferOwnershipToZero() public {
        console.log("\n--- [testTransferOwnershipToZero] BEFORE-Trigger ---");
        address initialOwner = token.getOwner();
        bool initialOwnerAuthStatus = token.isAuthorized(owner);
        console.log("Initial owner:", initialOwner);
        console.log("Initial authorization status of owner:", initialOwnerAuthStatus);

        console.log("--- TRIGGER: transferOwnership to zero address ---");
        vm.prank(owner);
        token.transferOwnership(payable(zeroAddress));

        console.log("\n--- AFTER-Trigger ---");
        address finalOwner = token.getOwner();
        bool finalOwnerAuthStatus = token.isAuthorized(owner);
        console.log("Final owner:", finalOwner);
        console.log("Final authorization status of original owner:", finalOwnerAuthStatus);

        // Existing assertions remain
        assertEq(finalOwner, zeroAddress, "Ownership transferred to zero");
        assertFalse(
            token.isAuthorized(owner), 
            "Original owner should lose authorization"
        );

        // Vulnerability verdict
        console.log("Vulnerability Exists: Owner can transfer ownership to zero address, breaking contract management");
    }

    function testCannotTransferToCurrentOwner() public {
        console.log("\n--- [testCannotTransferToCurrentOwner] BEFORE-Trigger ---");
        address initialOwner = token.getOwner();
        bool initialAuthStatus = token.isAuthorized(owner);
        console.log("Initial owner:", initialOwner);
        console.log("Initial authorization status:", initialAuthStatus);

        console.log("--- TRIGGER: Attempt transfer to current owner ---");
        vm.prank(owner);
        vm.expectRevert("Already the owner");
        token.transferOwnership(payable(owner));

        console.log("\n--- AFTER-Trigger ---");
        address finalOwner = token.getOwner();
        bool finalAuthStatus = token.isAuthorized(owner);
        console.log("Final owner:", finalOwner);
        console.log("Final authorization status:", finalAuthStatus);

        // Existing assertions remain
        assertEq(finalOwner, owner, "Ownership should remain unchanged");

        // Vulnerability verdict
        console.log("Vulnerability not Exist: Contract prevents transfer to current owner");
    }

    function testTransferToNewOwner() public {
        address newOwner = address(0xABC);
        
        console.log("\n--- [testTransferToNewOwner] BEFORE-Trigger ---");
        address initialOwner = token.getOwner();
        bool initialOwnerAuthStatus = token.isAuthorized(owner);
        bool initialNewOwnerAuthStatus = token.isAuthorized(newOwner);
        console.log("Initial owner:", initialOwner);
        console.log("Original owner auth state:", initialOwnerAuthStatus);
        console.log("New owner auth state (before):", initialNewOwnerAuthStatus);

        console.log("--- TRIGGER: Transfer to valid new owner ---");
        vm.prank(owner);
        token.transferOwnership(payable(newOwner));
        
        console.log("\n--- AFTER-Trigger ---");
        address finalOwner = token.getOwner();
        bool finalOwnerAuthStatus = token.isAuthorized(owner);
        bool finalNewOwnerAuthStatus = token.isAuthorized(newOwner);
        console.log("Final owner:", finalOwner);
        console.log("Original owner auth state (after):", finalOwnerAuthStatus);
        console.log("New owner auth state (after):", finalNewOwnerAuthStatus);

        // Existing assertions remain
        assertEq(finalOwner, newOwner, "Ownership not transferred");
        assertTrue(
            token.isAuthorized(newOwner), 
            "New owner should be authorized"
        );

        // Vulnerability verdict
        console.log("Vulnerability not Exist: Standard ownership transfer functions as intended");
    }
}