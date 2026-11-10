// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DripToken.sol";

contract MockPair {}

contract MockFactory {
    address immutable private pair;

    constructor(address _pair) {
        pair = _pair;
    }

    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
}

contract DripTokenFeeTest is Test {
    DripToken token;
    address owner = address(0x1);
    address constant routerAddr = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant wethAddr = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    function setUp() public {
        MockPair mockPair = new MockPair();
        MockFactory mockFactory = new MockFactory(address(mockPair));
        
        bytes memory routerCode = type(MockRouter).runtimeCode;
        vm.etch(routerAddr, routerCode);
        
        vm.store(
            routerAddr,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            routerAddr,
            bytes32(uint256(1)),
            bytes32(uint256(uint160(wethAddr)))
        );

        vm.prank(owner);
        token = new DripToken();
    }

    function test_FeeUpdateVulnerability() public {
        console2.log("--- Trigger FeeUpdateVulnerability Test ---");
        console2.log("BEFORE-ACTION: Attempt zero fee setting");
        // Verify zero fees don't revert (vulnerable condition)
        vm.prank(owner);
        token.set_All_Fees(0, 0);
        console2.log("SUCCESS: Zero fees accepted - Step1 passed");
        
        console2.log("AFTER-ACTION: Attempt non-zero fee setting");
        vm.prank(owner);
        token.set_All_Fees(10, 10);
        console2.log("SUCCESS: Non-zero fees accepted - Step2 passed");
        
        // Final verdict - vulnerability exists because zero fees were accepted without revert
        console2.log("Vulnerability Exists: Zero-fee setting allowed without validation");
    }

    function test_FeeValidation() public {
        console2.log("--- Trigger FeeValidation Test ---");
        console2.log("BEFORE-ACTION: Attempt exceeding max fee (100,101)");
        // Test fee maximum enforcement
        vm.prank(owner);
        vm.expectRevert("Max fee allowed is 20%");
        token.set_All_Fees(100, 101); // Exceeds 200 (20%)
        
        console2.log("SUCCESS: Revert occurred as expected");
        
        // Final verdict - checks work correctly
        console2.log("Vulnerability not Exist: Maximum fee enforcement working properly");
    }
}