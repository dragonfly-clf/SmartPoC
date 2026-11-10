// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StandardToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xdead);
    }
}

contract MockRouter {
    address public immutable factory;
    
    constructor(address _factory) {
        factory = _factory;
    }
}

contract UnprotectedMintTest is Test {
    StandardToken token;
    address owner = makeAddr("owner");
    address recipient = makeAddr("recipient");
    uint256 constant INITIAL_SUPPLY = 125 * 1e6 * 1e18;
    uint256 constant HUGE_MINT_AMOUNT = 1e9 * 1e18;

    function setUp() public {
        // Create mock contracts
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Simulate BSC router by setting mock code at known address
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(routerAddress, address(mockRouter).code);
        
        // Deploy the token
        vm.prank(owner);
        token = new StandardToken(owner);
    }

    function testUnlimitedMinting() public {
        console.log("--- BEFORE-Trigger State ---");
        // Query and log initial state
        uint256 initialTotalSupply = token.totalSupply();
        uint256 initialRecipientBalance = token.balanceOf(recipient);
        console.log("Initial total supply:", initialTotalSupply);
        console.log("Initial recipient balance:", initialRecipientBalance);
        assertEq(initialTotalSupply, INITIAL_SUPPLY, "Initial supply incorrect");

        console.log("--- Trigger Mint Operation ---");
        // Owner mints huge amount of tokens
        vm.prank(owner);
        token.mint(recipient, HUGE_MINT_AMOUNT);

        console.log("--- AFTER-Trigger State ---");
        // Query and log post-mint state
        uint256 finalTotalSupply = token.totalSupply();
        uint256 finalRecipientBalance = token.balanceOf(recipient);
        console.log("Final total supply:", finalTotalSupply);
        console.log("Final recipient balance:", finalRecipientBalance);

        // Calculate changes from minting operation
        uint256 expectedSupplyChange = HUGE_MINT_AMOUNT;
        uint256 actualSupplyChange = finalTotalSupply - initialTotalSupply;
        uint256 expectedBalanceChange = HUGE_MINT_AMOUNT;
        uint256 actualBalanceChange = finalRecipientBalance - initialRecipientBalance;

        // Differential validation results
        console.log("Total supply increased by:", actualSupplyChange);
        console.log("Recipient balance increased by:", actualBalanceChange);
        console.log("Vulnerability verdict:",
            (actualSupplyChange == expectedSupplyChange && 
             actualBalanceChange == expectedBalanceChange) ? 
            "MINT_SUCCESS" : "MINT_RESTRICTED"
        );

        // Vulnerability existence determination
        if (actualSupplyChange == expectedSupplyChange && 
            actualBalanceChange == expectedBalanceChange) {
            console.log("Vulnerability Exists: Owner could mint additional tokens without restrictions");
        } else {
            console.log("Vulnerability not Exist: Minting restrictions prevented unlimited token creation");
        }
    }
}