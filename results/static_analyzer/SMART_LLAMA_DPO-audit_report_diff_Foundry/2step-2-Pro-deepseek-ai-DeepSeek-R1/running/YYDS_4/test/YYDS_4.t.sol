// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/YYDS.sol";

contract MockUSDT {
    function approve(address, uint256) public pure returns (bool) {
        return true;
    }

    function balanceOf(address) public pure returns (uint256) {
        return 0;
    }

    // Added missing allowance function
    function allowance(address, address) public pure returns (uint256) {
        return 0;
    }
}

contract MockRouter {
    address public factory;
    
    function setFactory(address _factory) public {
        factory = _factory;
    }
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

contract YYDSPrivilegeTest is Test {
    YYDS public token;
    MockUSDT public mockUSDT;
    MockFactory public mockFactory;
    MockRouter public mockRouterImpl;

    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address owner = address(0x1);
    address marketingAddr = address(0x2);
    address treasureAddr = address(0x3);
    address shareholderAddr = address(0x4);
    address tokenOwner = address(0x5);
    address mockPair = address(0x9ABC);

    address testAddr = address(0x6);
    address testPair = address(0x7);

    function setUp() public {
        // Deploy mocks
        mockUSDT = new MockUSDT();
        mockFactory = new MockFactory(mockPair);
        mockRouterImpl = new MockRouter();

        // Set up mock storage for router
        mockRouterImpl.setFactory(address(mockFactory));

        // Patch environment for external dependencies
        vm.etch(USDT, address(mockUSDT).code);
        vm.etch(ROUTER, address(mockRouterImpl).code);
        vm.store(
            ROUTER,
            bytes32(0),
            bytes32(uint256(uint160(address(mockFactory))))
        );

        // Deploy token with patched environment
        vm.startPrank(owner);
        token = new YYDS(
            marketingAddr,
            treasureAddr,
            shareholderAddr,
            tokenOwner
        );
        vm.stopPrank();
    }

    function test_setPairAccess() public {
        console.log("--- BEFORE-Trigger setPair ---");
        bool beforeState = token.isPair(testPair);
        console.log("testPair in pair? ", beforeState);

        console.log("--- Trigger setPair ---");
        vm.prank(owner);
        token.setPair(testPair, true);

        console.log("--- AFTER-Trigger setPair ---");
        bool afterState = token.isPair(testPair);
        console.log("testPair in pair? ", afterState);

        if (!beforeState && afterState) {
            console.log("Vulnerability not Exist: setPair works as intended for owner");
        } else {
            console.log("Vulnerability Exists: setPair malfunction");
        }
    }

    function test_setWhitelistAccess() public {
        console.log("--- BEFORE-Trigger setWhitelist ---");
        bool beforeState = token.isWhitelist(testAddr);
        console.log("testAddr in whitelist? ", beforeState);

        console.log("--- Trigger setWhitelist ---");
        vm.prank(owner);
        token.setWhitelist(testAddr, true);

        console.log("--- AFTER-Trigger setWhitelist ---");
        bool afterState = token.isWhitelist(testAddr);
        console.log("testAddr in whitelist? ", afterState);

        if (!beforeState && afterState) {
            console.log("Vulnerability not Exist: setWhitelist works as intended for owner");
        } else {
            console.log("Vulnerability Exists: setWhitelist malfunction");
        }
    }

    function test_setBlcListAccess() public {
        console.log("--- BEFORE-Trigger setBlcList ---");
        bool beforeState = token.isBlclist(testAddr);
        console.log("testAddr in blacklist? ", beforeState);

        console.log("--- Trigger setBlcList ---");
        vm.prank(owner);
        token.setBlcList(testAddr, true);

        console.log("--- AFTER-Trigger setBlcList ---");
        bool afterState = token.isBlclist(testAddr);
        console.log("testAddr in blacklist? ", afterState);

        if (!beforeState && afterState) {
            console.log("Vulnerability not Exist: setBlcList works as intended for owner");
        } else {
            console.log("Vulnerability Exists: setBlcList malfunction");
        }
    }

    function test_nonOwnerCannotSetPair() public {
        console.log("--- BEFORE-Trigger nonOwner_setPair ---");
        bool beforeState = token.isPair(testPair);
        console.log("testPair in pair? ", beforeState);

        console.log("--- Trigger nonOwner_setPair ---");
        vm.prank(testAddr);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setPair(testPair, true);

        console.log("--- AFTER-Trigger nonOwner_setPair ---");
        bool afterState = token.isPair(testPair);
        console.log("testPair in pair? ", afterState);

        if (beforeState == afterState) {
            console.log("Vulnerability not Exist: Non-owner cannot setPair");
        } else {
            console.log("Vulnerability Exists: Non-owner successfully setPair");
        }
    }

    function test_nonOwnerCannotSetWhitelist() public {
        console.log("--- BEFORE-Trigger nonOwner_setWhitelist ---");
        bool beforeState = token.isWhitelist(testAddr);
        console.log("testAddr in whitelist? ", beforeState);

        console.log("--- Trigger nonOwner_setWhitelist ---");
        vm.prank(testAddr);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setWhitelist(testAddr, true);

        console.log("--- AFTER-Trigger nonOwner_setWhitelist ---");
        bool afterState = token.isWhitelist(testAddr);
        console.log("testAddr in whitelist? ", afterState);

        if (beforeState == afterState) {
            console.log("Vulnerability not Exist: Non-owner cannot setWhitelist");
        } else {
            console.log("Vulnerability Exists: Non-owner successfully setWhitelist");
        }
    }

    function test_nonOwnerCannotSetBlcList() public {
        console.log("--- BEFORE-Trigger nonOwner_setBlcList ---");
        bool beforeState = token.isBlclist(testAddr);
        console.log("testAddr in blacklist? ", beforeState);

        console.log("--- Trigger nonOwner_setBlcList ---");
        vm.prank(testAddr);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setBlcList(testAddr, true);

        console.log("--- AFTER-Trigger nonOwner_setBlcList ---");
        bool afterState = token.isBlclist(testAddr);
        console.log("testAddr in blacklist? ", afterState);

        if (beforeState == afterState) {
            console.log("Vulnerability not Exist: Non-owner cannot setBlcList");
        } else {
            console.log("Vulnerability Exists: Non-owner successfully setBlcList");
        }
    }
}