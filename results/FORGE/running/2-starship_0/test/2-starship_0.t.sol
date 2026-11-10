// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BABYTOKEN.sol";

contract MockDividendTracker {
    address public owner;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function initialize(address, uint256) external {
        owner = msg.sender;
    }
    
    function excludeFromDividends(address) external onlyOwner {}
}

contract MockUniswapFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xABCD);
    }
}

contract MockUniswapRouter {
    MockUniswapFactory public factory;
    address public immutable WETH = address(0x1);
    
    constructor() {
        factory = new MockUniswapFactory();
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, uint256, address[] calldata, address, uint256
    ) external pure {}
}

contract BABYTOKENBlacklistTest is Test {
    BABYTOKEN token;
    address owner;
    address marketingWallet;
    address user1;
    address user2;
    
    function setUp() public {
        owner = address(this);
        marketingWallet = address(0x5111);
        user1 = address(0x1111);
        user2 = address(0x2222);
        uint256 serviceFee = 1 ether;
        
        MockUniswapRouter mockRouter = new MockUniswapRouter();
        MockDividendTracker mockTracker = new MockDividendTracker();

        address[5] memory addrs = [
            address(0xCAFE),         // rewardToken
            address(mockRouter),      // router
            marketingWallet,          // marketing wallet
            address(mockTracker),     // dividendTracker implementation
            address(0xF00D)           // contractAddress
        ];
        
        uint256[4] memory buyFees = [uint256(1), 1, 1, 1];
        uint256[4] memory sellFees = [uint256(1), 1, 1, 1];
        
        vm.deal(owner, serviceFee);
        
        token = new BABYTOKEN{value: serviceFee}(
            "TestToken", 
            "TEST",
            100_000 ether,      // totalSupply
            addrs,
            buyFees,
            sellFees,
            1 ether,            // tokenBalanceForReward
            owner,
            serviceFee
        );
        
        token.transfer(user1, 1000 ether);
        token.transfer(user2, 1000 ether);
    }
    
    // Allow contract to receive ETH payments
    receive() external payable {}

    function testMassBlacklistBlocksTransfers() public {
        address[] memory bots = new address[](2);
        bots[0] = user1;
        bots[1] = user2;
        
        token.multipleBotlistAddress(bots, true);
        
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, 100 ether);

        vm.prank(user2);
        vm.expectRevert();
        token.transfer(user1, 100 ether);

        console.log("Vulnerability Exists: Blacklist blocks transfers from/to multiple blacklisted addresses");
    }

    function testBlacklistedSenderCannotTransfer() public {
        address[] memory bots = new address[](1);
        bots[0] = user1;
        token.multipleBotlistAddress(bots, true);
        
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(owner, 100 ether);

        console.log("Vulnerability Exists: Blacklisted sender cannot initiate transfers");
    }

    function testBlacklistedRecipientCannotReceive() public {
        address[] memory bots = new address[](1);
        bots[0] = user2;
        token.multipleBotlistAddress(bots, true);
        
        vm.prank(user1);
        vm.expectRevert();
        token.transfer(user2, 100 ether);

        console.log("Vulnerability Exists: Transfers to blacklisted recipients are blocked");
    }

    function testOwnerCanAddMultipleToBlacklist() public {
        address[] memory bots = new address[](10);
        for(uint256 i = 0; i < 10; i++) {
            bots[i] = address(uint160(i + 100));
        }
        
        token.multipleBotlistAddress(bots, true);
        
        for(uint256 i = 0; i < 10; i++) {
            address bot = address(uint160(i + 100));
            vm.prank(bot);
            vm.expectRevert();
            token.transfer(owner, 1);
        }

        console.log("Vulnerability Exists: Owner can blacklist multiple addresses simultaneously");
    }
}