// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOCTORSTRANGE.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdead);
    }
}

contract MockRouter {
    address public factory;
    address public weth;

    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}

contract DoctorStrangeFeeTest is Test {
    DOCTORSTRANGE token;
    address owner = address(0xa11ce);
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address wethAddress = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    function setUp() public {
        // Deploy mock factory and router
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), wethAddress);
        
        // Etch mock router code to expected address
        vm.etch(routerAddress, address(mockRouter).code);
        
        // Set storage for factory (slot 0)
        vm.store(
            routerAddress, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(mockFactory))))
        );
        
        // Set storage for weth (slot 1)
        vm.store(
            routerAddress, 
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(wethAddress)))
        );
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new DOCTORSTRANGE();
        vm.stopPrank();
    }

    function test_SetFeesBeyondLimit() public {
        console.log("\n===== FEE TEST STARTS =====");
        // Execute trigger operation - owner sets excessive fees
        console.log("--- NO CHECK - setFees(10,10,10,10,100) CALLED ---");
        bool feeSetSuccessfully = false;
        
        vm.startPrank(owner);
        try token.setFees(10, 10, 10, 10, 100) {
            feeSetSuccessfully = true;
        } catch {
            feeSetSuccessfully = false;
        }
        vm.stopPrank();

        if (feeSetSuccessfully) {
            console.log("Vulnerability Exists: Fee settings did not revert when set beyond safety limits");
        } else {
            console.log("Vulnerability not Exist: Fee settings reverted as expected");
        }
    }
    
    function test_SetDeadBlocksWithHighValue() public {
        console.log("\n===== DEAD BLOCKS TEST STARTS =====");
        
        // Query initial state
        console.log("--- BEFORE-TRIGGER SetDeadBlocks ---");
        uint deadBlocksBefore = token.deadBlocks();
        console.log("Initial Dead Blocks: ", deadBlocksBefore);
        
        // Execute trigger operation - owner sets excessively high dead blocks
        console.log("--- TRIGGER - setDeadBlocks(1000000) CALLED ---");
        vm.startPrank(owner);
        token.setDeadBlocks(1000000);
        vm.stopPrank();
        
        // Query post-trigger state
        console.log("--- AFTER-TRIGGER SetDeadBlocks ---");
        uint deadBlocksAfter = token.deadBlocks();
        console.log("Updated Dead Blocks: ", deadBlocksAfter);
        
        // Differential validation - dead blocks should be set to exactly 1,000,000
        bool deadBlocksChanged = deadBlocksAfter == 1000000;
        bool vulnerabilitiesExist = deadBlocksChanged;
        
        // Final vulnerability verdict
        if (vulnerabilitiesExist) {
            console.log("Vulnerability Exists: Successfully set dangerously high dead blocks (1,000,000)");
        } else {
            console.log("Vulnerability not Exist: Dead blocks weren't changed to expected value");
        }
    }
    
    function test_RevertWhen_NonOwnerTriesToSetFees() public {
        // Original authorization test remains unchanged
        vm.startPrank(address(0x1));
        vm.expectRevert(bytes("!AUTHORIZED"));
        token.setFees(10, 10, 10, 10, 100);
        vm.stopPrank();
    }
}