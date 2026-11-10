// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/VernyDoge.sol";

contract MockRouter {
    function factory() public pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
    
    function WETH() public pure returns (address) {
        return address(0xabcDefaBCdeFABCdefabCDeFAbCdeFABcDEFABcf);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x5678567856785678567856785678567856785678);
    }
}

contract VernyDogePrivilegeTest is Test {
    VernyDoge token;
    address owner = address(0xABCD);
    address newMarketingWallet = address(0x1234);
    address newTeamWallet = address(0x5678);
    
    address constant UNISWAP_V2_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY_ADDR = 0x1234567890123456789012345678901234567890;
    address constant MOCK_WETH_ADDR = 0xabcDefaBCdeFABCdefabCDeFAbCdeFABcDEFABcf;

    function setUp() public {
        // Deploy mock router and factory to get their runtime code
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Apply mock bytecode to fixed addresses
        vm.etch(UNISWAP_V2_ROUTER, address(mockRouter).code);
        vm.etch(MOCK_FACTORY_ADDR, address(mockFactory).code);
        
        // Set ETH balance for the router address for allowance operations
        vm.deal(UNISWAP_V2_ROUTER, 10 ether);
        
        // Deploy token contract as owner
        vm.prank(owner);
        token = new VernyDoge();
    }

    function testOwnerCanChangeCriticalParameters() public {
        vm.startPrank(owner);
        
        // Test updating liquify settings
        token.setSwapAndLiquifyEnabled(false);
        token.setSwapAndLiquifyByLimitOnly(true);
        
        // Test wallet changes
        token.setMarketingWalletAddress(newMarketingWallet);
        token.setTeamWalletAddress(newTeamWallet);
        
        // Test threshold updates
        token.setNumTokensBeforeSwap(2000 ether);
        token.setMaxTxAmount(1000 ether);
        
        // Verify parameter changes
        assertEq(token.swapAndLiquifyEnabled(), false, "Liquify enable not set");
        assertEq(token.swapAndLiquifyByLimitOnly(), true, "Liquify by limit not set");
        assertEq(token.marketingWalletAddress(), newMarketingWallet, "Marketing wallet not updated");
        assertEq(token.teamWalletAddress(), newTeamWallet, "Team wallet not updated");
        assertEq(token.minimumTokensBeforeSwapAmount(), 2000 ether, "Token swap threshold not updated");
        assertEq(token._maxTxAmount(), 1000 ether, "Max tx amount not updated"); // Fixed state variable
        
        vm.stopPrank();
    }

    function testNonOwnerCannotChangeParameters() public {
        address attacker = address(0x666);
        vm.deal(attacker, 1 ether);
        
        // Ensure known initial state for critical parameter
        vm.prank(owner);
        token.setSwapAndLiquifyEnabled(true);

        console.log("--- BEFORE-Trigger NonOwnerCall ---");
        // Record all key state variables
        bool swapEnabledBefore = token.swapAndLiquifyEnabled();
        bool swapByLimitBefore = token.swapAndLiquifyByLimitOnly();
        address marketingBefore = token.marketingWalletAddress();
        address teamBefore = token.teamWalletAddress();
        uint256 minTokensBefore = token.minimumTokensBeforeSwapAmount();
        uint256 maxTxBefore = token._maxTxAmount(); // Fixed: use underscore prefix
        
        // Log pre-trigger state
        console.log("swapAndLiquifyEnabled():", swapEnabledBefore);
        console.log("swapAndLiquifyByLimitOnly():", swapByLimitBefore);
        console.log("marketingWalletAddress():", marketingBefore);
        console.log("teamWalletAddress():", teamBefore);
        console.log("minimumTokensBeforeSwapAmount():", minTokensBefore);
        console.log("_maxTxAmount():", maxTxBefore);
        
        console.log("--- Trigger ---");
        console.log("Attacker calls setSwapAndLiquifyEnabled(false)");
        vm.prank(attacker);
        (bool success,) = address(token).call(
            abi.encodeWithSignature("setSwapAndLiquifyEnabled(bool)", false)
        );
        
        console.log("--- AFTER-Trigger NonOwnerCall ---");
        // Record post-trigger state
        bool swapEnabledAfter = token.swapAndLiquifyEnabled();
        bool swapByLimitAfter = token.swapAndLiquifyByLimitOnly();
        address marketingAfter = token.marketingWalletAddress();
        address teamAfter = token.teamWalletAddress();
        uint256 minTokensAfter = token.minimumTokensBeforeSwapAmount();
        uint256 maxTxAfter = token._maxTxAmount(); // Fixed: use underscore prefix
        
        // Log post-trigger state
        console.log("swapAndLiquifyEnabled():", swapEnabledAfter);
        console.log("swapAndLiquifyByLimitOnly():", swapByLimitAfter);
        console.log("marketingWalletAddress():", marketingAfter);
        console.log("teamWalletAddress():", teamAfter);
        console.log("minimumTokensBeforeSwapAmount():", minTokensAfter);
        console.log("_maxTxAmount():", maxTxAfter);
        
        // Verify if swapAndLiquifyEnabled changed as intended
        bool stateChanged = (swapEnabledAfter != swapEnabledBefore);
        console.log("Swap enabled state changed:", stateChanged);
        console.log("Attack succeeded:", success);
        
        // Final verdict based on state change
        if (stateChanged) {
            console.log("Vulnerability Exists: Non-owner successfully changed contract state");
        } else {
            console.log("Vulnerability not Exist: Critical parameters remain unchanged");
        }
    }
}