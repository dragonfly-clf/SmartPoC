// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FeelrToken.sol";

contract FeelrTokenTest is Test {
    FeelrToken public feelrToken;
    address public owner = vm.addr(1);
    address public nonOwner = vm.addr(2);
    address public feeAccount = vm.addr(3);

    function setUp() public {
        address dexRouterAddress = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address mockFactoryAddress = address(0x123);
        address mockWeth = address(0x456);
        address mockPair = address(0x789);
        
        // Helper selectors for mock calls
        bytes4 factorySelector = this.getSelector("factory()");
        bytes4 wethSelector = this.getSelector("WETH()");
        bytes4 createPairSelector = this.getSelector("createPair(address,address)");
        
        // Mock router factory call
        vm.mockCall(
            dexRouterAddress,
            abi.encodeWithSelector(factorySelector),
            abi.encode(mockFactoryAddress)
        );
        
        // Mock WETH call
        vm.mockCall(
            dexRouterAddress,
            abi.encodeWithSelector(wethSelector),
            abi.encode(mockWeth)
        );
        
        // Mock createPair call (match any args)
        vm.mockCall(
            mockFactoryAddress,
            abi.encodeWithSelector(createPairSelector),
            abi.encode(mockPair)
        );
        
        // Deploy contract with mocked dependencies
        vm.prank(owner);
        feelrToken = new FeelrToken();
    }
    
    // Helper function to compute function selectors
    function getSelector(string memory _func) public pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

    function testNonOwnerCannotExcludeFromFee() public {
        // Query initial fee exclusion status
        console.log("--- BEFORE-Trigger: Non-Owner Call ---");
        bool excludedBefore = feelrToken.isExcludedFromFee(feeAccount);
        console.log("Fee account excluded status before:", excludedBefore);

        // Attempt call as non-owner and expect revert
        console.log("--- Trigger: Non-owner call to includeOrExcludeFromFee ---");
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(nonOwner);
        feelrToken.includeOrExcludeFromFee(feeAccount, true);

        // Query post-call fee exclusion status
        console.log("--- AFTER-Trigger: Non-Owner Call ---");
        bool excludedAfter = feelrToken.isExcludedFromFee(feeAccount);
        console.log("Fee account excluded status after:", excludedAfter);

        // Vulnerability verdict
        if (excludedBefore != excludedAfter) {
            console.log("Vulnerability Exist: non-owner changed fee exclusion status");
        } else {
            console.log("Vulnerability not Exist: non-owner cannot change fee exclusion status");
        }
    }

    function testOwnerCanExcludeFromFee() public {
        // Query initial fee exclusion status
        console.log("--- BEFORE-Trigger: Owner Call ---");
        bool excludedBefore = feelrToken.isExcludedFromFee(feeAccount);
        console.log("Fee account excluded status before:", excludedBefore);
        assertEq(excludedBefore, false, "Initial should not be excluded");

        // Owner performs exclusion
        console.log("--- Trigger: Owner call to includeOrExcludeFromFee ---");
        vm.prank(owner);
        feelrToken.includeOrExcludeFromFee(feeAccount, true);

        // Verify exclusion status change
        console.log("--- AFTER-Trigger: Owner Call ---");
        bool excludedAfter = feelrToken.isExcludedFromFee(feeAccount);
        console.log("Fee account excluded status after:", excludedAfter);

        // Assert state change
        assertEq(excludedAfter, true, "Owner should exclude account");

        // Vulnerability verdict
        if (excludedAfter) {
            console.log("Vulnerability not Exist: owner successfully set fee exclusion");
        } else {
            console.log("Vulnerability Exist: failed to set fee exclusion with owner account");
        }
    }
}