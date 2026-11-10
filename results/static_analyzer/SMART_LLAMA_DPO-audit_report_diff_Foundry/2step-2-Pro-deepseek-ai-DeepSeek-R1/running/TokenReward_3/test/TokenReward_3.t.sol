// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TokenReward.sol";

contract TokenRewardTest is Test {
    TokenReward token;
    address constant ownerAddress = 0x8b4145a7a3c381E30de988F19D6958b4dA7aBD79;
    address constant pinkAntiBotAddr = 0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002;
    address constant routerAddr = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Mock dependencies
        vm.mockCall(
            pinkAntiBotAddr,
            abi.encodeWithSelector(bytes4(0x29c3510f), ownerAddress), // setTokenOwner(address)
            abi.encode()
        );
        
        address mockFactory = makeAddr("factory");
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(0xc45a0155)), // factory()
            abi.encode(mockFactory)
        );
        
        address wethAddr = makeAddr("WETH");
        vm.mockCall(
            routerAddr,
            abi.encodeWithSelector(bytes4(0xad5c4648)), // WETH()
            abi.encode(wethAddr)
        );
        
        address mockPair = makeAddr("initialPair");
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(bytes4(0xc9c65396)), // createPair()
            abi.encode(mockPair)
        );

        // Deploy token
        token = new TokenReward();
    }

    function testInsecurePairUpdate() public {
        // Get initial state
        address initialTokenOwner = token.owner();

        // Verify owner can be impersonated
        assertEq(initialTokenOwner, ownerAddress);

        // Prepare new arbitrary addresses
        address newPairAddress = makeAddr("invalidPair");
        address newLPAddress = makeAddr("invalidLPContract");

        console2.log("--- BEFORE-Trigger State ---");
        // Query and convert pair contract to address
        address prePairAddress = token.pairAddress();
        address prePairContractAddr = address(token.pairContract());
        console2.log("prePairAddress:", prePairAddress);
        console2.log("prePairContractAddr:", prePairContractAddr);
        
        console2.log("--- Trigger Operations: setPairAddress/setLP ---");
        // Perform state updates without validation
        vm.prank(ownerAddress);
        token.setPairAddress(newPairAddress);

        vm.prank(ownerAddress);
        token.setLP(newLPAddress);

        console2.log("--- AFTER-Trigger State ---");
        // Query and convert post-operation states
        address postPairAddress = token.pairAddress();
        address postPairContractAddr = address(token.pairContract());
        console2.log("postPairAddress:", postPairAddress);
        console2.log("postPairContractAddr:", postPairContractAddr);
        
        console2.log("--- Differential Results ---");
        // Check if critical pair addresses were manipulated
        bool pairAddressChanged = (postPairAddress != prePairAddress) && (postPairAddress == newPairAddress);
        bool pairContractChanged = (postPairContractAddr != prePairContractAddr) && (postPairContractAddr == newLPAddress);
        
        if (pairAddressChanged && pairContractChanged) {
            console2.log("Vulnerability Exists: The owner can arbitrarily update critical pair contracts without validation");
        } else {
            console2.log("Vulnerability not Exist: Pair contract states were not modified as expected");
        }
    }
}