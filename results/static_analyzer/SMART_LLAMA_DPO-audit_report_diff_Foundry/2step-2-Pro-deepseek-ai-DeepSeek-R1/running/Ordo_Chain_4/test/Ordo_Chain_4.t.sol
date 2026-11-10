// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Ordo_Chain.sol";

contract MockWBNB {
    // Minimal implementation for testing
}

contract MockPair {
    // Minimal implementation for testing
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockRouter {
    address public factory;
    
    function setFactory(address _factory) public {
        factory = _factory;
    }
}

contract OrdoChainPrivilegeTest is Test {
    Ordo_Chain public token;
    TaxPool public taxPool;
    address public owner = address(0x1);
    address public attacker = address(0x2);
    
    // Mainnet addresses
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy and setup mock contracts
        MockWBNB mockWBNB = new MockWBNB();
        vm.etch(WBNB_ADDRESS, address(mockWBNB).code);
        
        MockFactory mockFactory = new MockFactory();
        MockRouter tempRouter = new MockRouter();
        vm.etch(ROUTER_ADDRESS, address(tempRouter).code);
        
        MockRouter mockRouter = MockRouter(ROUTER_ADDRESS);
        mockRouter.setFactory(address(mockFactory));

        // Deploy contracts
        vm.startPrank(owner);
        token = new Ordo_Chain();
        taxPool = new TaxPool();
        vm.stopPrank();
    }

    function testOwnerSucceedsForCriticalFunctions() public {
        vm.startPrank(owner);

        token.setTax(type(uint256).max);
        token.setTaxDivider(type(uint256).max);
        token.setTaxPool(address(taxPool));
        
        vm.stopPrank();
        console.log("Vulnerability not Exist: Required authorization for owner is working");
    }

    function testAttackerFailsForSetTax() public {
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTax(5000);
        console.log("Vulnerability not Exist: Access control protects setTax");
    }

    function testAttackerFailsForSetTaxDivider() public {
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxDivider(10000);
        console.log("Vulnerability not Exist: Access control protects setTaxDivider");
    }

    function testAttackerFailsForSetTaxPool() public {
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxPool(address(taxPool));
        console.log("Vulnerability not Exist: Access control protects setTaxPool");
    }

    function testOwnerCantSetZeroAddress() public {
        vm.prank(owner);
        vm.expectRevert(bytes("Zero Address."));
        token.setTaxPool(address(0));
        console.log("Vulnerability not Exist: Zero address protection works");
    }
}