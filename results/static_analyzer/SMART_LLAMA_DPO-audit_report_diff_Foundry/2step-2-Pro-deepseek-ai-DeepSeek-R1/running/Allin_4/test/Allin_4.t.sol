// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Allin.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockRouter {
    address public factory;
    constructor(address _factory) {
        factory = _factory;
    }
}

contract MockWBNB {}

contract AllinPrivilegeTest is Test {
    Allin token;
    address owner = address(0x1);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    // Corrected Snapshot struct with proper types
    struct Snapshot {
        bool swapEnabled;
        uint256 swapThreshold;
        uint256 maxTxAmount;
        bool tradingOpen;
        bool buyCooldownEnabled;
        uint256 cooldownTimerInterval;
        bool autoBuybackMultiplier;  // Now correctly typed as bool
    }

    function setUp() public {
        // Deploy mock router, factory and WBNB
        MockFactory mockF = new MockFactory();
        MockRouter mockR = new MockRouter(address(mockF));
        MockWBNB mockW = new MockWBNB();
        
        // Point hardcoded addresses to mock contracts
        vm.etch(ROUTER_ADDRESS, address(mockR).code);
        vm.store(ROUTER_ADDRESS, bytes32(0), bytes32(uint256(uint160(address(mockF)))));
        vm.etch(WBNB_ADDRESS, address(mockW).code);
        
        // Deploy Allin from owner address
        vm.startPrank(owner);
        token = new Allin();
        vm.stopPrank();
    }
    
    // Take snapshot of current token settings
    function _takeSnapshot() internal view returns (Snapshot memory) {
        return Snapshot({
            swapEnabled: token.swapEnabled(),
            swapThreshold: token.swapThreshold(),
            maxTxAmount: token._maxTxAmount(),
            tradingOpen: token.tradingOpen(),
            buyCooldownEnabled: token.buyCooldownEnabled(),
            cooldownTimerInterval: token.cooldownTimerInterval(),
            autoBuybackMultiplier: token.autoBuybackMultiplier()  // Correctly matches property type
        });
    }
    
    // Util function to log snapshot details
    function _logSnapshot(string memory name, Snapshot memory s) internal {
        console.log("--- %s State ---", name);
        console.log("swapEnabled: %s", s.swapEnabled ? "true" : "false");
        console.log("swapThreshold: %d", s.swapThreshold);
        console.log("maxTxAmount: %d", s.maxTxAmount);
        console.log("tradingOpen: %s", s.tradingOpen ? "true" : "false");
        console.log("buyCooldownEnabled: %s", s.buyCooldownEnabled ? "true" : "false");
        console.log("cooldownTimerInterval: %d", s.cooldownTimerInterval);
        console.log("autoBuybackMultiplier: %s", s.autoBuybackMultiplier ? "true" : "false");
        console.log("");
    }

    function test_owner_can_change_critical_settings() public {
        console.log("--- BEFORE Settings Change ---");
        Snapshot memory before = _takeSnapshot();
        _logSnapshot("Initial State", before);
        
        // Calculate intended tx limit
        uint256 intendedTxLimit = token.totalSupply() / 1000;
        
        vm.startPrank(owner);
        console.log("--- Changing Settings ---");
        
        token.setBuybackMultiplierSettings(2, 1, 10);        // Set buyback multiplier
        token.setTargetLiquidity(50, 100);                   // Set liquidity target
        token.setSwapBackSettings(true, 1 ether);            // Enable swap back
        token.setTxLimit(intendedTxLimit);                   // Set transaction limit
        token.setDistributionCriteria(1 hours, 1 ether);     // Set distribution criteria
        token.setDistributorSettings(500000);                // Set distributor gas
        token.tradingStatus(true);                           // Enable trading
        token.cooldownEnabled(true, 1);                      // Enable cooldown
        
        vm.stopPrank();
        
        console.log("--- AFTER Settings Change ---");
        Snapshot memory after_ = _takeSnapshot();
        _logSnapshot("Final State", after_);
        
        // Check if any setting changed
        bool vulnerable = 
            before.swapEnabled != after_.swapEnabled ||
            before.swapThreshold != after_.swapThreshold ||
            before.maxTxAmount != after_.maxTxAmount ||
            before.tradingOpen != after_.tradingOpen ||
            before.buyCooldownEnabled != after_.buyCooldownEnabled ||
            before.cooldownTimerInterval != after_.cooldownTimerInterval ||
            before.autoBuybackMultiplier != after_.autoBuybackMultiplier;

        // Final vulnerability determination
        if (vulnerable) {
            console.log("Vulnerability Exists: Critical settings changed arbitrarily by owner");
        } else {
            console.log("Vulnerability not Exist: No critical settings changed");
        }
    }
}