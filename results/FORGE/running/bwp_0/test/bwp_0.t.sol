// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BWORKER.sol";

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
}

contract MockFactory {
    address public pairAddress;

    constructor(address _pairAddress) {
        pairAddress = _pairAddress;
    }

    function createPair(address, address) external view returns (address) {
        return pairAddress;
    }
}

contract MockPair {
    address public token0;
    address public token1;
    uint112 public reserve0;
    uint112 public reserve1;

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
        reserve0 = 1000;
        reserve1 = 1000;
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, 0);
    }
}

contract MockNFT {
    function totalProfitAt(uint256) external pure returns (uint256) {
        return 1 ether;
    }
}

contract OwnerMintTest is Test {
    BWORKER token;
    MockNFT nftContract;
    address owner = address(0x1);
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDR = address(0x123);

    function setUp() public {
        // Setup mock router, factory, and pair
        MockPair mockPair = new MockPair(WETH_ADDR, address(this));
        MockFactory mockFactory = new MockFactory(address(mockPair));
        MockRouter mockRouter = new MockRouter(address(mockFactory), WETH_ADDR);
        
        // Bind mock router to predefined address
        vm.etch(ROUTER_ADDR, address(mockRouter).code);

        vm.startPrank(owner);
        token = new BWORKER();
        vm.stopPrank();

        // Setup NFT contract and configuration
        nftContract = new MockNFT();
        
        vm.startPrank(owner);
        token.setNFTContract(address(nftContract));
        token.setGameValidator(owner, true);
        vm.stopPrank();

        // Advance time to satisfy epoch requirements
        vm.warp(block.timestamp + 3 days);
    }

    function test_owner_can_mint_tokens_arbitrarily() public {
        console.log("--- BEFORE-Trigger TotalSupply ---");
        uint256 initialSupply = token.totalSupply();
        console.log("Initial total supply:", initialSupply);

        console.log("--- Trigger manualMintProfit ---");
        vm.prank(owner);
        token.manualMintProfit();

        console.log("--- AFTER-Trigger TotalSupply ---");
        uint256 finalSupply = token.totalSupply();
        console.log("Final total supply:", finalSupply);

        if (finalSupply > initialSupply) {
            console.log("Vulnerability Exists: Owner can arbitrarily mint tokens, increasing total supply by", finalSupply - initialSupply);
        } else {
            console.log("Vulnerability not Exist: Token supply remains unchanged after owner mint attempt");
        }
    }
}