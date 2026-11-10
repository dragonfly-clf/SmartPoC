// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Oracula.sol";

contract MockPancakeFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        return address(uint160(uint(keccak256(abi.encodePacked(tokenA, tokenB)))));
    }
}

contract MockPancakePair {} // Added for realistic exchange simulation

contract MockPancakeRouter {
    address public immutable factory;
    address public immutable WETH = address(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);

    constructor(address _factory) {
        factory = _factory;
    }
}

contract OraculaTransferFeeTest is Test {
    Oracula token;
    address owner = address(this);
    address userA = address(0x1);
    address userB = address(0x2);
    address devAddress = address(0x3);
    address rewardAddress = address(0x4);
    address pancakePair; // Added exchange pair address
    
    uint256 constant TOKEN_AMOUNT = 1000 * 10**18;
    uint256 constant TRANSFER_AMOUNT = 100 * 10**18;
    uint256 constant BURN_FEE = 1;
    uint256 constant DEV_FEE = 1;
    uint256 constant REWARD_FEE = 1;

    function setUp() public {
        // Create and deploy mocks
        MockPancakeFactory mockFactory = new MockPancakeFactory();
        MockPancakeRouter mockRouter = new MockPancakeRouter(address(mockFactory));
        
        // Override hardcoded router address with our mock
        vm.etch(0x10ED43C718714eb63d5aA57B78B54704E256024E, address(mockRouter).code);
        
        // Create mock PancakeSwap pair address
        pancakePair = address(new MockPancakePair());
        
        // Deploy token with acceptable fee values
        token = new Oracula(
            devAddress,
            rewardAddress,
            BURN_FEE,
            DEV_FEE,
            REWARD_FEE
        );
        
        // Set initial balances for testing
        token.transfer(userA, TOKEN_AMOUNT);
        token.transfer(pancakePair, TOKEN_AMOUNT); // Fund exchange pair
    }

    // Added helper to capture all relevant balances pre/post action
    function getFeeRelevantBalances() internal view returns (
        uint256 senderBalance,
        uint256 exchangeBalance,
        uint256 devBalance,
        uint256 rewardBalance,
        uint256 contractBalance
    ) {
        senderBalance = token.balanceOf(userA);
        exchangeBalance = token.balanceOf(pancakePair);
        devBalance = token.balanceOf(devAddress);
        rewardBalance = token.balanceOf(rewardAddress);
        contractBalance = token.balanceOf(address(token));
    }

    function testNormalTransferWithoutFees() public {
        // Pre-transfer balances
        uint256 balanceA_before = token.balanceOf(userA);
        uint256 balanceB_before = token.balanceOf(userB);

        // Perform transfer between non-exchange pair addresses
        vm.prank(userA);
        token.transfer(userB, TRANSFER_AMOUNT);

        // Post-transfer balances
        uint256 balanceA_after = token.balanceOf(userA);
        uint256 balanceB_after = token.balanceOf(userB);

        // Verify no fees were deducted
        assertEq(
            balanceB_after,
            balanceB_before + TRANSFER_AMOUNT,
            "Recipient should receive full amount without fees"
        );
        assertEq(
            balanceA_after,
            balanceA_before - TRANSFER_AMOUNT,
            "Sender should be deducted exact amount without fees"
        );
    }

    function testTransferBetweenExcludedAddresses() public {
        // Exclude users from fees
        vm.prank(owner);
        token.changeFeeStatus(userA, true);
        vm.prank(owner);
        token.changeFeeStatus(userB, true);

        // Pre-transfer balances
        uint256 balanceA_before = token.balanceOf(userA);
        uint256 balanceB_before = token.balanceOf(userB);

        // Perform transfer between excluded addresses
        vm.prank(userA);
        token.transfer(userB, TRANSFER_AMOUNT);

        // Post-transfer balances
        uint256 balanceA_after = token.balanceOf(userA);
        uint256 balanceB_after = token.balanceOf(userB);

        // Verify no fees were deducted
        assertEq(
            balanceB_after,
            balanceB_before + TRANSFER_AMOUNT,
            "Excluded recipient should receive full amount"
        );
        assertEq(
            balanceA_after,
            balanceA_before - TRANSFER_AMOUNT,
            "Excluded sender should be deducted exact amount"
        );
    }

    // New test method for exchange pair transfers with fees
    function testTransferFeesToExchangePair() public {
        console2.log("--- BEFORE-Trigger Exchange Pair Balances ---");
        (
            uint256 senderBalBefore,
            uint256 pairBalBefore,
            uint256 devBalBefore,
            uint256 rewardBalBefore,
            uint256 tokenContractBalBefore
        ) = getFeeRelevantBalances();
        
        console2.log("Sender (userA) balance:     ", senderBalBefore);
        console2.log("Exchange Pair balance:      ", pairBalBefore);
        console2.log("Dev Address balance:        ", devBalBefore);
        console2.log("Reward Address balance:     ", rewardBalBefore);
        console2.log("Token Contract balance:     ", tokenContractBalBefore);
        
        console2.log("\n--- Trigger Transfer to Exchange Pair ---");
        vm.prank(userA);
        token.transfer(pancakePair, TRANSFER_AMOUNT);
        
        console2.log("\n--- AFTER-Trigger Exchange Pair Balances ---");
        (
            uint256 senderBalAfter,
            uint256 pairBalAfter,
            uint256 devBalAfter,
            uint256 rewardBalAfter,
            uint256 tokenContractBalAfter
        ) = getFeeRelevantBalances();
        
        console2.log("Sender (userA) balance:     ", senderBalAfter);
        console2.log("Exchange Pair balance:      ", pairBalAfter);
        console2.log("Dev Address balance:        ", devBalAfter);
        console2.log("Reward Address balance:     ", rewardBalAfter);
        console2.log("Token Contract balance:     ", tokenContractBalAfter);
        
        // Calculate balance changes
        int256 senderChange = int256(senderBalAfter) - int256(senderBalBefore);
        int256 pairChange = int256(pairBalAfter) - int256(pairBalBefore);
        int256 devChange = int256(devBalAfter) - int256(devBalBefore);
        int256 rewardChange = int256(rewardBalAfter) - int256(rewardBalBefore);
        int256 tokenContractChange = int256(tokenContractBalAfter) - int256(tokenContractBalBefore);
        int256 totalSupplyChange = senderChange + pairChange + devChange + rewardChange + tokenContractChange;
        
        console2.log("\n--- Balance Changes ---");
        console2.log("Sender Change:            ", senderChange);
        console2.log("Exchange Pair Received:   ", pairChange);
        console2.log("Dev Fee Collected:        ", devChange);
        console2.log("Reward Fee Collected:     ", rewardChange);
        console2.log("Token Contract Change:    ", tokenContractChange);
        console2.log("Total Supply Change:      ", totalSupplyChange);
        
        // Vulnerability verdict logic
        bool senderDeductionCorrect = senderChange == -int256(TRANSFER_AMOUNT);
        bool feesCollected = (devChange > 0 || rewardChange > 0 || tokenContractChange != 0);
        bool pairReceivedPartial = pairChange < int256(TRANSFER_AMOUNT);
        
        if (senderDeductionCorrect && feesCollected && pairReceivedPartial) {
            console2.log("\nVulnerability not Exist: Fee deduction occurred normally during exchange transfer");
        } else {
            console2.log("\nVulnerability Exists: Abnormal fee deduction during exchange transfer");
        }
    }
}