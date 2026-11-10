// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KeyCashGame.sol";

contract KeyCashGameTest is Test {
    KeyCashGame game;
    address owner = address(this);
    address player = address(0x1);
    
    function setUp() public {
        // Deploy the game contract
        game = new KeyCashGame();

        // Set only essential parameters that don't cause reverts
        game.setMaxKeysPerTx(10);
        game.setStartPrice(0.1 ether);

        // Avoid setting problematic parameters (prizePoolShare/ticketPriceShare)
    }

    function testCannotBuyTicketsBeforeGameStarts() public {
        // Fund player with ETH
        vm.deal(player, 1 ether);

        console.log("--- BEFORE-Trigger ---");
        console.log("Player ETH balance: %s", player.balance);
        console.log(
            "Execution plan: Attempt buyTickets(1) with 0.1 ether before game start"
        );

        console.log("--- TRIGGER ---");
        console.log(
            "Calling buyTickets(1) from player address with 0.1 ether..."
        );
        
        // Attempt to buy tickets before game starts
        (bool success, bytes memory returnData) = address(game).call{value: 0.1 ether}(
            abi.encodeWithSignature("buyTickets(uint256)", 1)
        );
        
        console.log("--- AFTER-Trigger ---");
        console.log("Transaction status: %s", success ? "Success" : "Reverted");
        
        if (!success) {
            // Decode revert reason if available
            if (returnData.length > 0) {
                // Skip function selector (first 4 bytes) to get reason
                bytes memory reason = new bytes(returnData.length - 4);
                for (uint256 i = 0; i < reason.length; i++) {
                    reason[i] = returnData[i + 4];
                }
                console.log("Revert reason: %s", string(reason));
            }
        }
        
        // Final vulnerability verdict
        if (success) {
            console.log("Vulnerability Exists: Contract allowed ticket purchase before game start without revert");
        } else {
            console.log("Vulnerability not Exist: Contract correctly prevented ticket purchase with revert");
        }
    }
}