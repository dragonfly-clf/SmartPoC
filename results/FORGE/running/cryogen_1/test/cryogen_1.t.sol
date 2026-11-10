// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BABYTOKEN.sol";

contract MockToken is ERC20Upgradeable {
    function initialize() public initializer {
        __ERC20_init("MockToken", "MOCK");
        _mint(msg.sender, 10000 * 10**18);
    }
}

contract MockFactory {
    address public immutable pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function getPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable weth;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        weth = _weth;
    }
    
    function WETH() external view returns (address) {
        return weth;
    }
}

contract MockPair {}

contract BabyTokenFeeTest is Test {
    BABYTOKEN token;
    address owner = address(this);
    address marketingWallet = address(0x1);
    MockToken rewardToken;
    address mockPair;
    MockFactory factory;
    MockRouter router;
    uint256 minimumTokenBalance = 100;
    bytes4 createPairSelector = 0xc9c65396;

    function setUp() public {
        vm.startPrank(owner);
        
        rewardToken = new MockToken();
        rewardToken.initialize();

        mockPair = address(new MockPair());
        factory = new MockFactory(mockPair);
        router = new MockRouter(address(factory), address(0));
        
        address weth = router.WETH();
        vm.mockCall(
            address(factory),
            abi.encodePacked(createPairSelector, abi.encode(address(0), weth)), // Placeholder until we know token address
            abi.encode(mockPair)
        );
        
        token = new BABYTOKEN();
        
        vm.mockCall(
            address(factory),
            abi.encodePacked(createPairSelector, abi.encode(address(token), weth)),
            abi.encode(mockPair)
        );
        
        address[4] memory initAddrs = [
            owner,
            address(rewardToken),
            address(router),
            marketingWallet
        ];
        
        token.initialize(
            initAddrs,
            "BabyToken",
            "BABY",
            1000000 * 10**18,
            0,   // Initial tokenRewardsFee (0%)
            0,   // Initial liquidityFee (0%)
            0,   // Initial marketingFee (0%)
            minimumTokenBalance
        );
        
        vm.stopPrank();
    }

    function test_OwnerCanSetUnlimitedFees() public {
        console.log("--- BEFORE-Trigger Fees ---");
        uint256 initialRewardFee = token.tokenRewardsFee();
        uint256 initialMarketingFee = token.marketingFee();
        uint256 initialLiquidityFee = token.liquidityFee();
        console.log("Initial tokenRewardsFee:", initialRewardFee);
        console.log("Initial marketingFee:", initialMarketingFee);
        console.log("Initial liquidityFee:", initialLiquidityFee);
        
        // Verify initial fees are set to 0
        assertEq(initialRewardFee, 0, "Initial token rewards fee should be 0");
        assertEq(initialMarketingFee, 0, "Initial marketing fee should be 0");
        assertEq(initialLiquidityFee, 0, "Initial liquidity fee should be 0");
        
        console.log("--- Trigger SetFees (to 100) ---");
        vm.startPrank(owner);
        // Attempt to set fees to 100% (handle reverts safely)
        try token.setTokenRewardsFee(100) {} catch {}
        try token.setMarketingFee(100) {} catch {}
        try token.setLiquiditFee(100) {} catch {}
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger Fees ---");
        uint256 newRewardFee = token.tokenRewardsFee();
        uint256 newMarketingFee = token.marketingFee();
        uint256 newLiquidityFee = token.liquidityFee();
        console.log("New tokenRewardsFee:", newRewardFee);
        console.log("New marketingFee:", newMarketingFee);
        console.log("New liquidityFee:", newLiquidityFee);

        // Vulnerability verification: Check if any fee exceeds 15% cap
        bool feesExceedCap = newRewardFee > 15 || 
                            newMarketingFee > 15 || 
                            newLiquidityFee > 15;
        
        if (feesExceedCap) {
            console.log("Vulnerability Exists: Owner can set fees beyond 15% cap");
        } else {
            console.log("Vulnerability not Exist: Fees are within 15% cap");
        }
    }
}