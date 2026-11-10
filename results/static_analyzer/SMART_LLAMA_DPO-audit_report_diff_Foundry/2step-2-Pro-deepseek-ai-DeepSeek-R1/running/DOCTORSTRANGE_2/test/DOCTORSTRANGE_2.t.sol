// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOCTORSTRANGE.sol";

contract MockFactory {
    address public token0;
    address public token1;

    function createPair(address _tokenA, address _tokenB) external returns (address) {
        token0 = _tokenA;
        token1 = _tokenB;
        return address(0x1); // Return dummy pair address
    }
}

contract MockRouter {
    address public immutable factory;

    constructor() {
        factory = address(new MockFactory());
    }
}

contract AuthVulnerabilityTest is Test {
    DOCTORSTRANGE token;
    address deployer = makeAddr("deployer");
    address authAddress = makeAddr("authorized_address");
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function setUp() public {
        // Deploy MockRouter and MockFactory
        MockRouter mockRouter = new MockRouter();
        // Store mock router bytecode at hardcoded router address
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        // Store factory address in storage slot 0 at router address
        vm.store(ROUTER_ADDRESS, bytes32(0), bytes32(abi.encode(mockRouter.factory())));

        // Deploy token contract
        vm.startPrank(deployer);
        token = new DOCTORSTRANGE();
        vm.stopPrank();
    }

    function testDuplicateAuthorizations() public {
        // Verify initial state
        assertEq(token.getOwner(), deployer, "Deployer should be owner");

        vm.startPrank(deployer);
        // Authorize address
        token.authorize(authAddress);
        assertTrue(token.isAuthorized(authAddress), "Should be authorized after first call");

        // Authorize again (duplicate)
        token.authorize(authAddress);
        assertTrue(token.isAuthorized(authAddress), "Should still be authorized after duplicate call");

        // Remove authorization
        token.unauthorize(authAddress);
        assertFalse(token.isAuthorized(authAddress), "Should be unauthorized after removal");
        vm.stopPrank();

        // Final vulnerability verdict
        console.log("Vulnerability not Exist: Authorization state handles duplicates correctly without unexpected behavior");
    }
}