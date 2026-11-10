// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PPIG.sol";

contract MockWETH {
    // Minimal implementation for WETH mock
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        // Return a fixed address for the pair
        return address(0xabc);
    }
}

contract MockRouter {
    address public immutable WETH;
    address public immutable factory;
    
    constructor(address _weth, address _factory) {
        WETH = _weth;
        factory = _factory;
    }
}

contract PPIGPrivilegeEscalationTest is Test {
    PPIG public token;
    address public owner = address(0x1);
    address public attacker = address(0x2);
    address public newMktWallet = address(0x3);
    
    function setUp() public {
        // Setup mock router environment
        
        // Deploy mocks
        MockWETH mockWeth = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockWeth), address(mockFactory));
        
        // Set the hardcoded router address (0x10ED43C718714eb63d5aA57B78B54704E256024E) to mock router's code
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(mockRouter).code);
        
        // Deploy PPIG contract as owner
        vm.startPrank(owner);
        token = new PPIG();
        vm.stopPrank();
    }

    function test_owner_can_change_mktWallet() public {
        vm.prank(owner);
        token.setMktWallet(payable(newMktWallet));
        
        // Owner can set marketing wallet to any arbitrary address
        assertEq(token.mktWallet(), newMktWallet);
    }

    function test_nonowner_cannot_change_mktWallet() public {
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMktWallet(payable(newMktWallet));
    }
    
    function test_owner_can_enable_trading() public {
        console.log("--- BEFORE-Trigger trading status ---");
        bool tradeStatusBefore = token.trade();
        console.log("Trade status before calling GoTrade:", tradeStatusBefore);
        console.log("Expected initial state: false (trading disabled)");

        console.log("--- Trigger: Owner calls GoTrade ---");
        vm.prank(owner);
        token.GoTrade();

        console.log("--- AFTER-Trigger trading status ---");
        bool tradeStatusAfter = token.trade();
        console.log("Trade status after calling GoTrade:", tradeStatusAfter);

        console.log("--- Differential Verification ---");
        console.log("State changed from %s to %s", 
            tradeStatusBefore, 
            tradeStatusAfter
        );
        
        if (tradeStatusBefore == tradeStatusAfter) {
            console.log("Vulnerability Exists: Trade status unchanged after owner action");
            console.log("Vulnerability Exists: Trade status unchanged by owner call");
        } else if (tradeStatusAfter) {
            console.log(
                "Vulnerability not Exist: Trade status successfully changed (false -> true)"
            );
        } else {
            console.log("Vulnerability Exists: Unexpected trade status after owner call");
            console.log("Vulnerability Exists: Unexpected trade state after owner call");
        }
    }
    
    function test_nonowner_cannot_enable_trading() public {
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.GoTrade();
    }
}