// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PILOTDOGE.sol";

contract MockToken {
    mapping(address => uint256) public balanceOf;

    function mint(address account, uint256 amount) external {
        balanceOf[account] += amount;
    }

    function transfer(address, uint256) external pure returns (bool) {
        return false; // Returns false on transfer
    }
}

contract MockTokenReverting {
    function transfer(address, uint256) external pure returns (bool) {
        revert("Transfer failed");
    }
}

contract MockTokenSucceeds {
    function transfer(address, uint256) external pure returns (bool) {
        return true;
    }
}

contract PILOTDOGETest is Test {
    PILOTDOGE public pdoge;
    MockToken public mockToken;
    MockTokenReverting public mockTokenReverting;
    MockTokenSucceeds public mockTokenSucceeds;
    
    address constant DEV = address(0xD3A);
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant targetAddress = address(0x123);
    uint256 constant rescueAmount = 100;

    function setUp() public {
        // Set up mocks for Uniswap router and factory
        address mockFactory = address(0x123);
        address mockWETH = address(0x456);
        address mockPair = address(0x789);
        
        // Mock router functions
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock factory's createPair to accept any token pair
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Deploy PILOTDOGE after setting up mocks
        pdoge = new PILOTDOGE();
        
        // Deploy mock tokens
        mockToken = new MockToken();
        mockTokenReverting = new MockTokenReverting();
        mockTokenSucceeds = new MockTokenSucceeds();
        
        // Set DEV address
        vm.prank(pdoge.owner());
        pdoge.setNewDevAddress(payable(DEV));
    }

    // Test that rescueForeignTokens ignores false return value
    function test_RescueForeignTokensIgnoresFalseReturn() public {
        // Set initial state with tokens in contract
        mockToken.mint(address(pdoge), 1000);

        // Log pre-trigger state
        console.log("--- BEFORE-Trigger State ---");
        uint256 pdogeBalanceBefore = mockToken.balanceOf(address(pdoge));
        uint256 targetBalanceBefore = mockToken.balanceOf(targetAddress);
        console.log("PILOTDOGE contract token balance:", pdogeBalanceBefore);
        console.log("Target address token balance:", targetBalanceBefore);

        console.log("--- Trigger Operation: rescueForeignTokens ---");
        // Execute rescue function
        vm.prank(DEV);
        pdoge.rescueForeignTokens(address(mockToken), targetAddress, rescueAmount);

        console.log("--- AFTER-Trigger State ---");
        uint256 pdogeBalanceAfter = mockToken.balanceOf(address(pdoge));
        uint256 targetBalanceAfter = mockToken.balanceOf(targetAddress);
        console.log("PILOTDOGE contract token balance:", pdogeBalanceAfter);
        console.log("Target address token balance:", targetBalanceAfter);

        // Comparison and verdict
        bool unchangedState = (pdogeBalanceAfter == pdogeBalanceBefore) && 
                              (targetBalanceAfter == targetBalanceBefore);
        
        console.log("--- Vulnerability Verification ---");
        if (unchangedState) {
            console.log("State remains unchanged after failed rescue operation");
            console.log("Vulnerability Exists: Function ignores false return value without reverting");
        } else {
            console.log("State changed unexpectedly despite transfer failure");
            console.log("Vulnerability not Exist: Function exhibits unexpected behavior");
        }
    }

    // Test that rescueForeignTokens doesn't handle reverts - unchanged
    function test_RescueForeignTokensRevertsOnFailure() public {
        vm.prank(DEV);
        vm.expectRevert("Transfer failed");
        pdoge.rescueForeignTokens(address(mockTokenReverting), address(0x123), 100);
    }

    // Test that successful transfer works - unchanged
    function test_RescueForeignTokensWorksOnSuccess() public {
        vm.prank(DEV);
        pdoge.rescueForeignTokens(address(mockTokenSucceeds), address(0x123), 100);
    }
}