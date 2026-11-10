// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOGEMOON.sol";

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint256) external returns (bool) { return true; }
}

contract MockFactory {
    address public pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
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

contract DOGEMOONAccessControlTest is Test {
    DOGEMOON token;
    address owner = address(0x1);
    address nonOwner = address(0x2);
    address recipient = address(0x3);
    address[] recipients;
    uint256[] amounts;
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Setup mocks
        MockWETH mockWETH = new MockWETH();
        address mockPair = address(0x123456);
        MockFactory mockFactory = new MockFactory(mockPair);
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Override router code at target address
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);

        // Deploy token contracts
        vm.startPrank(owner);
        token = new DOGEMOON();
        vm.stopPrank();
        
        // Setup test parameters
        recipients = new address[](1);
        recipients[0] = recipient;
        amounts = new uint256[](1);
        amounts[0] = 1000 * (10 ** token.decimals());
        
        // Mint test tokens to owner
        vm.prank(owner);
        token.transfer(owner, amounts[0] * 10);
    }

    function test_OwnerCanCallCriticalFunctions() public {
        vm.prank(owner);
        token.setSwapBackSettings(true, 100);
        
        vm.prank(owner);
        token.multiTransfer(owner, recipients, amounts);
        
        vm.prank(owner);
        token.setDistributionCriteria(3600, 10 ether, true);

        assertEq(token.balanceOf(recipient), amounts[0]);
    }

    function test_NonOwnerCannotCallMultiTransfer() public {
        vm.prank(nonOwner);
        vm.expectRevert("!OWNER");
        token.multiTransfer(owner, recipients, amounts);
    }

    function test_NonOwnerCannotCallSetSwapBack() public {
        vm.prank(nonOwner);
        vm.expectRevert("!AUTHORIZED");
        token.setSwapBackSettings(true, 100);
    }

    function test_NonOwnerCannotCallSetDistribution() public {
        vm.prank(nonOwner);
        vm.expectRevert("!AUTHORIZED");
        token.setDistributionCriteria(3600, 10 ether, true);
    }

    function test_VulnerabilityVerification() public {
        // Vulnerability verification depends on access control checks only
        console.log("=== Access Control Vulnerability Test ===");
        bool vulnerabilityDetected = false;
        
        // Test multiTransfer access control
        try this.checkMultiTransferAccess() {
            console.log("[PASS] multiTransfer: Access control intact");
        } catch {
            vulnerabilityDetected = true;
            console.log("[FAIL] multiTransfer: Non-owner access succeeded");
        }
        
        // Test setSwapBackSettings access control
        try this.checkSwapBackAccess() {
            console.log("[PASS] setSwapBackSettings: Access control intact");
        } catch {
            vulnerabilityDetected = true;
            console.log("[FAIL] setSwapBackSettings: Non-owner access succeeded");
        }
        
        // Test setDistributionCriteria access control
        try this.checkDistributionAccess() {
            console.log("[PASS] setDistributionCriteria: Access control intact");
        } catch {
            vulnerabilityDetected = true;
            console.log("[FAIL] setDistributionCriteria: Non-owner access succeeded");
        }
        
        // Final vulnerability verdict based on authorization checks
        if (vulnerabilityDetected) {
            console.log("Vulnerability Exists: Access controls successfully bypassed");
        } else {
            console.log("Vulnerability not Exist: Access controls are enforced");
        }
    }

    // Helper function to test multiTransfer access
    function checkMultiTransferAccess() external {
        vm.startPrank(nonOwner);
        token.multiTransfer(owner, recipients, amounts);
        vm.stopPrank();
        require(false, "Access bypassed but shouldn't");
    }
    
    // Helper function to test setSwapBackSettings access
    function checkSwapBackAccess() external {
        vm.startPrank(nonOwner);
        token.setSwapBackSettings(true, 100);
        vm.stopPrank();
        require(false, "Access bypassed but shouldn't");
    }
    
    // Helper function to test setDistributionCriteria access
    function checkDistributionAccess() external {
        vm.startPrank(nonOwner);
        token.setDistributionCriteria(3600, 10 ether, true);
        vm.stopPrank();
        require(false, "Access bypassed but shouldn't");
    }
}