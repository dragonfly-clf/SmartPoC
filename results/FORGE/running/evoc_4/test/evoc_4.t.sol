// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/EvocPlus.sol";

// Helper contract to get address bytecode using assembly
contract CodeHelper {
    function getCode(address _addr) public view returns (bytes memory o_code) {
        assembly {
            // Get the size of the code
            let size := extcodesize(_addr)
            // Allocate output byte array
            o_code := mload(0x40)
            // Update free memory pointer
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // Store length
            mstore(o_code, size)
            // Copy the code
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
        }
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890ABCDEF);
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xCAFEFE);
    }
    
    function WETH() external pure returns (address) {
        return address(0);
    }
}

contract EvocPlusBlacklistTest is Test {
    EvocPlus token;
    CodeHelper codeHelper;
    address owner = address(0x1);
    address user = address(0x2);
    address attacker = address(0x3);
    
    // Router address from contract
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY_ADDRESS = address(0xCAFEFE);
    address constant MOCK_PAIR_ADDRESS = address(0x1234567890ABCDEF);

    function setUp() public {
        // Deploy helper and mocks
        codeHelper = new CodeHelper();
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Get bytecode for router and factory
        bytes memory routerCode = codeHelper.getCode(address(mockRouter));
        bytes memory factoryCode = codeHelper.getCode(address(mockFactory));
        
        // Patch addresses with mock contracts
        vm.etch(ROUTER_ADDRESS, routerCode);
        vm.etch(MOCK_FACTORY_ADDRESS, factoryCode);
        vm.etch(MOCK_PAIR_ADDRESS, "dummycode");
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new EvocPlus();
        vm.stopPrank();
    }

    function test_OwnerCanBlacklistAddress() public {
        console.log("--- BEFORE-Trigger State Snapshot ---");
        bool beforeDevlisted = token._isDevlisted(user);
        console.log("_isDevlisted(user) before:", beforeDevlisted ? "true" : "false");

        console.log("--- Trigger: owner calls devListAddress(user, true) ---");
        vm.prank(owner);
        token.devListAddress(user, true);

        console.log("--- AFTER-Trigger State Snapshot ---");
        bool afterDevlisted = token._isDevlisted(user);
        console.log("_isDevlisted(user) after:", afterDevlisted ? "true" : "false");

        bool changed = (beforeDevlisted != afterDevlisted);
        console.log("State changed:", changed ? "YES" : "NO");

        if (beforeDevlisted == false && afterDevlisted == true) {
            console.log("Vulnerability Exists: devListAddress changed _isDevlisted(user) from false to true");
        } else {
            console.log("Vulnerability not Exist: devListAddress did not change _isDevlisted(user) from false to true");
        }
    }

    function test_NonOwnerCannotBlacklist() public {
        vm.prank(attacker);
        vm.expectRevert("!AUTHORIZED");
        token.devListAddress(user, true);
    }
}