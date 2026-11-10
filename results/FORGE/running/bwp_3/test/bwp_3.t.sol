// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BWORKER.sol";

contract MockNFT {
    function totalProfitAt(uint256) external pure returns (uint256) {
        return 1 ether;
    }
}

contract MockRouter {
    address public factory;
    address public WETH;

    function initialize(address _factory, address _weth) public {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    address public lastPair;
    address public token0;
    address public token1;

    function createPair(address _tokenA, address _tokenB) external returns (address) {
        token0 = _tokenA;
        token1 = _tokenB;
        lastPair = address(new MockPair(_tokenA, _tokenB));
        return lastPair;
    }
}

contract MockPair {
    address public token0;
    address public token1;
    uint112 public reserve0 = 1000;
    uint112 public reserve1 = 1000;
    uint32 public blockTimestampLast = uint32(block.timestamp);

    constructor(address _token0, address _token1) {
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, blockTimestampLast);
    }
}

contract TotalSupplyDiversionTest is Test {
    BWORKER token;
    MockNFT mockNFT;
    address internal treasuryReceiver;
    uint256 initialSupply;
    address constant routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant wethAddress = address(0xDeaD);
    address gameBalanceHolder;

    function setUp() public {
        // Deploy MockFactory
        MockFactory mockFactory = new MockFactory();
        
        // Deploy MockRouter to get code
        MockRouter mockRouter = new MockRouter();
        bytes memory routerCode = address(mockRouter).code;
        vm.etch(routerAddress, routerCode);
        
        // Initialize router
        MockRouter(routerAddress).initialize(address(mockFactory), wethAddress);
        
        // Deploy token and record Transfer event to get treasury receiver
        vm.recordLogs();
        token = new BWORKER();
        initialSupply = token.totalSupply();
        
        // Parse logs to get treasury address from Transfer event
        Vm.Log[] memory logs = vm.getRecordedLogs();
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == keccak256("Transfer(address,address,uint256)")) {
                // First topic is event signature, second is from, third is to
                if (address(uint160(uint256(logs[i].topics[1]))) == address(0)) {
                    // Found mint Transfer to treasury
                    treasuryReceiver = address(uint160(uint256(logs[i].topics[2])));
                    break;
                }
            }
        }
        require(treasuryReceiver != address(0), "Treasury not found");
        
        // Fast-forward 2 days to create epochs
        vm.warp(block.timestamp + 2 days);
        
        // Setup mock NFT and record holder
        mockNFT = new MockNFT();
        gameBalanceHolder = address(mockNFT);
        token.setNFTContract(gameBalanceHolder);
    }

    function testTotalSupplyDiversion() public {
        // Capture key metrics BEFORE trigger
        uint256 preSupply = token.totalSupply();
        uint256 preTreasury = token.balanceOf(treasuryReceiver);
        uint256 preGame = token.gameBalanceOf(gameBalanceHolder);
        
        console.log("--- BEFORE DIFF STATE ---");
        console.log("Total Supply      :", preSupply);
        console.log("Treasury Balance  :", preTreasury);
        console.log("Game Balance      :", preGame);
        
        // Trigger critical vulnerability
        console.log("--- TRIGGER: manualMintProfit() ---");
        token.manualMintProfit();
        
        // Capture key metrics AFTER trigger
        uint256 postSupply = token.totalSupply();
        uint256 postTreasury = token.balanceOf(treasuryReceiver);
        uint256 postGame = token.gameBalanceOf(gameBalanceHolder);
        
        console.log("--- AFTER DIFF STATE ---");
        console.log("Total Supply      :", postSupply);
        console.log("Treasury Balance  :", postTreasury);
        console.log("Game Balance      :", postGame);
        
        // Calculate state changes
        uint256 supplyChange = postSupply - preSupply;
        uint256 gameChange = postGame - preGame;
        bool unallocated = gameChange == 0 && supplyChange > 0;
        bool partialAllocation = gameChange > 0 && gameChange < supplyChange;
        
        console.log("--- CHANGES ---");
        console.log("Supply change    :", supplyChange);
        console.log("Game balance diff:", gameChange);
        console.log("Unallocated tokens:", supplyChange - gameChange);
        
        // Vulnerability decision logic
        console.log("--- VULNERABILITY VERDICT ---");
        if (unallocated) {
            console.log("Vulnerability Exists: All minted tokens unallocated (0 added to game balance)");
        } else if (partialAllocation) {
            console.log("Vulnerability Exists: Partial token allocation (%s tokens unaccounted)", supplyChange - gameChange);
        } else if (gameChange == supplyChange) {
            console.log("Vulnerability not Exist: All tokens properly allocated to game balance");
        } else {
            console.log("Vulnerability not Exist: Game balance increased more than supply change");
        }
    }
}