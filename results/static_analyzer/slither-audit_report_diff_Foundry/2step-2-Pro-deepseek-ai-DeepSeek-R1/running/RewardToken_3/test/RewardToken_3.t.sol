pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RewardToken.sol";

// Failing ERC20 token implementation
contract FailingERC20 {
    uint8 public decimals;
    mapping(address => uint256) public balanceOf;

    constructor(uint8 _decimals) {
        decimals = _decimals;
        balanceOf[msg.sender] = 1_000_000 * 10**_decimals;
    }

    function transfer(address, uint256) external pure returns (bool) {
        // Always returns false to simulate failed transfer
        return false;
    }
}

// Mock Router with necessary functionality
contract MockRouter {
    address public immutable WETH;
    address public factory;

    constructor(address _weth) {
        WETH = _weth;
        factory = address(new MockFactory());
    }

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256,
        uint256,
        address[] calldata,
        address,
        uint256
    ) external {
        // Empty implementation for testing
    }
}

// Mock Factory for router
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

// Main test contract
contract RewardTokenTest is Test {
    RewardToken token;
    FailingERC20 failingRewardToken;
    MockRouter router;
    address constant WETH_ADDRESS = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    
    // Test addresses
    address owner = makeAddr("owner");
    address marketingWallet = makeAddr("marketing");
    address user = makeAddr("user");
    uint256 constant TOTAL_SUPPLY = 1_000_000 * 1e18;

    function setUp() public {
        vm.startPrank(owner);
        
        // Setup failing reward token and router
        failingRewardToken = new FailingERC20(18);
        router = new MockRouter(WETH_ADDRESS);
        
        // Initialize RewardToken with failing reward token
        uint256[] memory fees = new uint256[](3);
        fees[0] = 1; // liquidityFee
        fees[1] = 1; // marketingFee
        fees[2] = 0; // extrasellFee
        
        token = new RewardToken{value: 0}(
            "TestToken", 
            "TST",
            TOTAL_SUPPLY / 1e18, // Supply in base units
            18, // Decimals
            address(failingRewardToken), // Failing reward token
            1, // rewardsFee
            1, // minTokens
            fees,
            marketingWallet,
            address(router),
            owner
        );
        
        // Configure token settings
        token.excludeFromFees(user, true);
        token.transfer(user, TOTAL_SUPPLY / 2);
        token.excludeFromFees(user, false);
        token.setSwapAmount(100 * 1e18); // Low swap threshold
        
        vm.stopPrank();
    }

    // Test that transfer ignores failing reward token transfer
    function test_TransferFailureIgnored() public {
        vm.prank(user);
        address recipient = makeAddr("recipient");
        
        bool success;
        
        console.log("--- Trigger Transfer ---");
        try token.transfer(recipient, (TOTAL_SUPPLY / 2) * 15 / 100) {
            console.log("Transfer completed without revert");
            success = true;
        } catch {
            console.log("Transfer unexpectedly reverted");
            success = false;
        }

        // Vulnerability validation verdict
        if (success) {
            console.log("Vulnerability Exists: transfer succeeded without reverting despite failing reward token transfer");
        } else {
            console.log("Vulnerability not Exist: transfer reverted during failing reward token transfer");
        }
    }
}