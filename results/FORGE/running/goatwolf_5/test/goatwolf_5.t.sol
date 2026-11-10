// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoatWolf.sol";

// Mock contracts to simulate external dependencies
contract MockRouter {
    address public immutable factory;
    address public constant WETH = address(0x1);
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xABCD);
    }
}

contract GoatWolfTest is Test {
    GoatWolf token;
    address constant BSC_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address owner = address(0x1234);
    address user = address(0x5678);
    
    function setUp() public {
        // Mock external dependencies
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Set contract code at router address
        vm.etch(BSC_ROUTER, address(mockRouter).code);
        vm.etch(0x1234567890123456789012345678901234567890, address(mockFactory).code);
        
        // Deploy token
        vm.startPrank(owner);
        token = new GoatWolf();
        vm.stopPrank();
    }

    function test_PercentWalletAllowsInvalidValues() public {
        console.log("--- BEFORE-Trigger pCent Values ---");
        uint256 pCent0_before = token.pCent(0);
        uint256 pCent1_before = token.pCent(1);
        uint256 pCent2_before = token.pCent(2);
        console.log("pCent[0] before:", pCent0_before);
        console.log("pCent[1] before:", pCent1_before);
        console.log("pCent[2] before:", pCent2_before);
        
        console.log("--- Trigger setPercentWallet ---");
        uint256[3] memory invalidPercentages = [uint256(60), 50, 10];
        vm.prank(owner);
        token.setPercentWallet(invalidPercentages);
        
        console.log("--- AFTER-Trigger pCent Values ---");
        uint256 pCent0_after = token.pCent(0);
        uint256 pCent1_after = token.pCent(1);
        uint256 pCent2_after = token.pCent(2);
        console.log("pCent[0] after:", pCent0_after);
        console.log("pCent[1] after:", pCent1_after);
        console.log("pCent[2] after:", pCent2_after);
        
        // Validate state changes
        bool changedToInvalid = (pCent0_after == 60) && 
                                (pCent1_after == 50) && 
                                (pCent2_after == 10);
        
        if (changedToInvalid) {
            console.log("VERIFICATION: pCent successfully set to invalid values (sum=120)");
            console.log("Vulnerability Exists: Contract allowed setting invalid percentages");
        } else {
            console.log("VERIFICATION: pCent was NOT set to invalid values");
            console.log("Vulnerability not Exist: Contract prevented invalid percentage setting");
        }
    }
}