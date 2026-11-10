// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TokenTool.sol";

// Mock contracts replace interface declarations
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xbeef);
    }
}

contract MockRouter {
    address private immutable _factory;
    address private immutable _weth;

    constructor(address factoryAddr, address wethAddr) {
        _factory = factoryAddr;
        _weth = wethAddr;
    }
    
    function factory() external view returns (address) {
        return _factory;
    }
    
    function WETH() external view returns (address) {
        return _weth;
    }
}

contract TokenToolPrivilegeTest is Test {
    TokenTool token;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address marketing = makeAddr("marketing");
    address team = makeAddr("team");
    
    // Mocks
    MockFactory mockFactory;
    MockRouter mockRouter;
    address constant mockWeth = address(0xdead);

    function setUp() public {
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory), mockWeth);

        // Set ETH balance for owner
        vm.deal(owner, 10 ether);
        
        vm.prank(owner);
        token = new TokenTool{value: 0}(
            "PrivilegeTestToken",
            "PTT",
            18,
            1000000 * 10**18,
            address(mockRouter),
            owner,
            marketing,
            team,
            address(0)  // Service address
        );
    }

    function testSwapManipulation() public {
        console.log("--- START testSwapManipulation ---");
        // State variables to monitor
        bool initialSwapEnabled;
        uint256 initialSwapThreshold;
        bool initialSwapMode;
        
        // Verify owner can toggle swap features
        console.log("--- BEFORE: setSwapAndLiquifyEnabled(false) ---");
        initialSwapEnabled = token.swapAndLiquifyEnabled();
        console.log("Initial swapAndLiquifyEnabled: %s", initialSwapEnabled);
        
        console.log("--- CALL: setSwapAndLiquifyEnabled(false) ---");
        vm.prank(owner);
        token.setSwapAndLiquifyEnabled(false);
        
        console.log("--- AFTER: setSwapAndLiquifyEnabled(false) ---");
        bool updatedSwapEnabled = token.swapAndLiquifyEnabled();
        console.log("Updated swapAndLiquifyEnabled: %s", updatedSwapEnabled);
        console.log("Changed: %s", updatedSwapEnabled == !initialSwapEnabled ? "YES" : "NO");
        
        // Verify owner can change swap thresholds
        console.log("--- BEFORE: setNumTokensBeforeSwap ---");
        initialSwapThreshold = token.minimumTokensBeforeSwapAmount();
        console.log("Initial swap threshold: %s", initialSwapThreshold);
        
        console.log("--- CALL: setNumTokensBeforeSwap(10*1e18) ---");
        vm.prank(owner);
        token.setNumTokensBeforeSwap(10 * 10**18);
        
        console.log("--- AFTER: setNumTokensBeforeSwap ---");
        uint256 updatedSwapThreshold = token.minimumTokensBeforeSwapAmount();
        console.log("Updated swap threshold: %s", updatedSwapThreshold);
        console.log("Changed: %s", updatedSwapThreshold != initialSwapThreshold ? "YES" : "NO");
        
        // Verify owner can change swap modes
        console.log("--- BEFORE: setSwapAndLiquifyByLimitOnly ---");
        initialSwapMode = token.swapAndLiquifyByLimitOnly();
        console.log("Initial swap mode: %s", initialSwapMode);
        
        console.log("--- CALL: setSwapAndLiquifyByLimitOnly(true) ---");
        vm.prank(owner);
        token.setSwapAndLiquifyByLimitOnly(true);
        
        console.log("--- AFTER: setSwapAndLiquifyByLimitOnly ---");
        bool updatedSwapMode = token.swapAndLiquifyByLimitOnly();
        console.log("Updated swap mode: %s", updatedSwapMode);
        console.log("Changed: %s", updatedSwapMode == !initialSwapMode ? "YES" : "NO");
        
        console.log("--- END testSwapManipulation ---\n");
    }

    function testWalletManipulation() public {
        console.log("--- START testWalletManipulation ---");
        // State variables to monitor
        address initialMarketing;
        address initialTeam;
        address newMarketing = makeAddr("newMarketing");
        address newTeam = makeAddr("newTeam");
        
        // Verify owner can redirect fee wallets
        console.log("--- BEFORE: setMarketingWalletAddress ---");
        initialMarketing = token.marketingWalletAddress();
        console.log("Initial marketing wallet: %s", initialMarketing);
        
        console.log("--- CALL: setMarketingWalletAddress ---");
        vm.prank(owner);
        token.setMarketingWalletAddress(newMarketing);
        
        console.log("--- AFTER: setMarketingWalletAddress ---");
        address updatedMarketing = token.marketingWalletAddress();
        console.log("Updated marketing wallet: %s", updatedMarketing);
        console.log("Changed: %s", updatedMarketing != initialMarketing ? "YES" : "NO");
        
        console.log("--- BEFORE: setTeamWalletAddress ---");
        initialTeam = token.teamWalletAddress();
        console.log("Initial team wallet: %s", initialTeam);
        
        console.log("--- CALL: setTeamWalletAddress ---");
        vm.prank(owner);
        token.setTeamWalletAddress(newTeam);
        
        console.log("--- AFTER: setTeamWalletAddress ---");
        address updatedTeam = token.teamWalletAddress();
        console.log("Updated team wallet: %s", updatedTeam);
        console.log("Changed: %s", updatedTeam != initialTeam ? "YES" : "NO");
        
        // Should prevent others from changing wallets
        console.log("--- BEFORE: attacker setMarketingWalletAddress ---");
        address preAttackMarketing = token.marketingWalletAddress();
        
        console.log("--- CALL: attacker setMarketingWalletAddress ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMarketingWalletAddress(attacker);
        
        console.log("--- AFTER: attacker setMarketingWalletAddress ---");
        address postAttackMarketing = token.marketingWalletAddress();
        console.log("Marketing wallet unchanged: %s", 
            preAttackMarketing == postAttackMarketing ? "YES" : "NO");
            
        console.log("--- END testWalletManipulation ---\n");
    }

    function testLimitManipulation() public {
        console.log("--- START testLimitManipulation ---");
        // State variable to monitor
        uint256 initialMaxTx;
        
        // Verify owner can remove transaction limits
        console.log("--- BEFORE: setMaxTxAmount ---");
        initialMaxTx = token._maxTxAmount();
        console.log("Initial maxTX: %s", initialMaxTx);
        
        console.log("--- CALL: setMaxTxAmount(5000000*1e18) ---");
        vm.prank(owner);
        token.setMaxTxAmount(5000000 * 10**18);
        
        console.log("--- AFTER: setMaxTxAmount ---");
        uint256 updatedMaxTx = token._maxTxAmount();
        console.log("Updated maxTX: %s", updatedMaxTx);
        console.log("Changed: %s", updatedMaxTx != initialMaxTx ? "YES" : "NO");
        
        // Verify owner can completely disable limits
        console.log("--- BEFORE: disable limits ---");
        uint256 preDisableMaxTx = token._maxTxAmount();
        
        console.log("--- CALL: setMaxTxAmount(0) ---");
        vm.prank(owner);
        token.setMaxTxAmount(0);
        
        console.log("--- AFTER: disable limits ---");
        uint256 postDisableMaxTx = token._maxTxAmount();
        console.log("Changed: %s", postDisableMaxTx == 0 ? "YES" : "NO");
        
        // Should prevent others from changing limits
        console.log("--- BEFORE: attacker setMaxTxAmount ---");
        uint256 preAttackMaxTx = token._maxTxAmount();
        
        console.log("--- CALL: attacker setMaxTxAmount ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMaxTxAmount(type(uint256).max);
        
        console.log("--- AFTER: attacker setMaxTxAmount ---");
        uint256 postAttackMaxTx = token._maxTxAmount();
        console.log("MaxTx unchanged: %s", 
            preAttackMaxTx == postAttackMaxTx ? "YES" : "NO");
            
        console.log("--- END testLimitManipulation ---\n");
    }

    function testUnauthorizedAccess() public {
        console.log("--- START testUnauthorizedAccess ---");
        bool vulnerabilityFound = false;
        
        // Validate attacker cannot change swap settings
        console.log("--- BEFORE (all states): ---");
        bool preSwapEnabled = token.swapAndLiquifyEnabled();
        address preMarketing = token.marketingWalletAddress();
        uint256 preMaxTx = token._maxTxAmount();
        console.log("swapEnabled:%s | marketing:%s | maxTx:%s",
            preSwapEnabled, preMarketing, preMaxTx);
        
        console.log("--- ATTACKER ACTION: setSwapAndLiquifyEnabled ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setSwapAndLiquifyEnabled(false);
        
        console.log("--- AFTER: setSwapAndLiquifyEnabled ---");
        bool postSwapEnabled = token.swapAndLiquifyEnabled();
        if (postSwapEnabled != preSwapEnabled) {
            console.log("STATE CHANGE: swapAndLiquifyEnabled: %s -> %s",
                preSwapEnabled, postSwapEnabled);
            vulnerabilityFound = true;
        }
        
        // Validate attacker cannot change wallets
        console.log("--- ATTACKER ACTION: setMarketingWalletAddress ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMarketingWalletAddress(attacker);
        
        console.log("--- AFTER: setMarketingWalletAddress ---");
        address postMarketing = token.marketingWalletAddress();
        if (postMarketing != preMarketing) {
            console.log("STATE CHANGE: marketing: %s -> %s",
                preMarketing, postMarketing);
            vulnerabilityFound = true;
        }
        
        // Validate attacker cannot change transaction limits
        console.log("--- ATTACKER ACTION: setMaxTxAmount ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMaxTxAmount(type(uint256).max);
        
        console.log("--- AFTER: setMaxTxAmount ---");
        uint256 postMaxTx = token._maxTxAmount();
        if (postMaxTx != preMaxTx) {
            console.log("STATE CHANGE: maxTx: %s -> %s",
                preMaxTx, postMaxTx);
            vulnerabilityFound = true;
        }
        
        // Final verdict
        if (vulnerabilityFound) {
            console.log("Vulnerability Exists: Non-owner modified contract state");
        } else {
            console.log("Vulnerability not Exist: Non-owner could not modify contract state");
        }
        console.log("--- END testUnauthorizedAccess ---");
    }
}