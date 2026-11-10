// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CH.sol";

contract MockERC20 {
    function approve(address, uint256) external pure returns (bool) {
        return true;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xABCD);
    }
}

contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract CH_Fee_Test is Test {
    address constant BUSD_ADDRESS = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    CH token;
    address deployer = makeAddr("deployer");

    function setUp() public {
        // Deploy mock contracts
        MockERC20 mockBUSD = new MockERC20();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Assign mock bytecode to hardcoded addresses
        vm.etch(BUSD_ADDRESS, address(mockBUSD).code);
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        
        // Deploy CH token
        vm.startPrank(deployer);
        token = new CH();
        vm.stopPrank();
    }

    function test_set_excessive_sell_fee() public {
        uint256 excessiveFee = 2600; // 26% (exceeding 25% limit)

        console.log("--- BEFORE-Trigger Action ---");
        console.log("_sellLPFee state variable: Private (not externally accessible)");
        console.log("Attempting to set fee to 26%...");

        console.log("--- Trigger setSellLPFee ---");
        vm.startPrank(deployer);
        try token.setSellLPFee(excessiveFee) {
            // Transaction does NOT revert = vulnerability exists
            console.log("--- AFTER-Trigger Action ---");
            console.log("Transaction result: setSellLPFee succeeded");
            console.log("Vulnerability Exists: Owner can set fee beyond 25% limit without revert");
        } catch Error(string memory reason) {
            // Transaction reverts = vulnerability remediated
            console.log("--- AFTER-Trigger Action ---");
            console.log("Transaction result: Reverted ->", reason);
            console.log("Vulnerability not Exist: Fee limit enforcement reverts excessive settings");
            fail(); 
        } catch (bytes memory lowLevelData) {
            console.log("--- AFTER-Trigger Action ---");
            console.log("Transaction result: Low-level revert");
            console.log("Vulnerability not Exist: Fee limit enforcement reverts excessive settings");
            fail(); 
        }
        vm.stopPrank();
    }
}