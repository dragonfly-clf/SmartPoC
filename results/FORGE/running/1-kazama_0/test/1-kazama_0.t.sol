// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KazamaSenshi.sol";

// Mock contracts to replace external dependencies
contract MockRouter {
    address public immutable factory;
    address public immutable WBNB;
    
    constructor(address _factory, address _wbnb) {
        factory = _factory;
        WBNB = _wbnb;
    }
    
    function WETH() external pure returns (address) {
        return address(0x123);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x456);
    }
}

contract MockWBNB {
    function deposit() external payable {}
    function transfer(address, uint) external pure returns (bool) { return true; }
    function approve(address, uint) external pure returns (bool) { return true; }
}

contract MintTest is Test {
    KazamaSenshi public token;
    address public owner = address(0x1);
    address public alice = address(0x2);
    
    // Router address that matches contract's hardcoded value
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Deploy mock dependencies
        MockWBNB mockWBNB = new MockWBNB();
        MockFactory mockFactory = new MockFactory();
        
        // Initialize mock router
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWBNB));
        
        // Override the hardcoded router address with mock implementation
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        
        // Set required storage slots for mock router
        vm.store(
            ROUTER_ADDR, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            ROUTER_ADDR, 
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(address(mockWBNB))))
        );
        
        // Deploy token with required constructor parameters
        vm.startPrank(owner);
        token = new KazamaSenshi();  // Name and symbol pre-set in contract
        
        // Grant necessary privileges
        token.recruitZaibatsu(owner);
        token.raiseJin(owner);
        token.raiseSenshiMaster(owner);  // Grant minting role to owner
        vm.stopPrank();
    }
    
    function testMintTokens_InflationRisk() public {
        // BEFORE: Capture pre-state
        uint256 preTotalSupply = token.totalSupply();
        uint256 preAliceBalance = token.balanceOf(alice);
        uint256 mintAmount = 1000 * 10 ** token.decimals();

        console.log("--- BEFORE-Trigger Mint ---");
        console.log("Alice's Balance    :", preAliceBalance);
        console.log("Total Supply       :", preTotalSupply);
        console.log("Mint Amount        :", mintAmount);

        // TRIGGER: Mint operation
        console.log("--- Trigger Mint ---");
        vm.prank(owner);
        token.mint(alice, mintAmount);

        // AFTER: Capture post-state
        uint256 postTotalSupply = token.totalSupply();
        uint256 postAliceBalance = token.balanceOf(alice);

        console.log("--- AFTER-Trigger Mint ---");
        console.log("Alice's New Balance:", postAliceBalance);
        console.log("Updated Supply     :", postTotalSupply);

        // Calculate state changes
        uint256 aliceDelta = postAliceBalance - preAliceBalance;
        uint256 supplyDelta = postTotalSupply - preTotalSupply;

        console.log("Alice Balance Delta:", aliceDelta);
        console.log("Total Supply Delta :", supplyDelta);

        // Vulnerability analysis
        bool inflationOccurred = (aliceDelta == mintAmount) && 
                                 (supplyDelta == mintAmount);

        // Final vulnerability verdict
        if (inflationOccurred) {
            console.log("Vulnerability Exists: Owner successfully minted tokens without restrictions, causing inflation");
        } else {
            console.log("Vulnerability not Exist: Token state changes do not match minting inputs");
        }
    }
}