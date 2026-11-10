// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/bsc.sol";

contract bscStateEventTest is Test {
    bsc token;
    address owner = makeAddr("owner");
    address newWallet = makeAddr("newWallet");
    address user = makeAddr("user");
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant BSC_WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;

    MockFactory mockFactory;
    MockRouter mockRouter;

    function setUp() public {
        vm.startPrank(owner);
        // Deploy mock contracts
        mockFactory = new MockFactory();
        mockRouter = new MockRouter(address(mockFactory), BSC_WETH);
        
        // Override router address with mock implementation
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.store(
            ROUTER_ADDRESS, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            ROUTER_ADDRESS, 
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(BSC_WETH)))
        );
        
        // Deploy token contract
        token = new bsc();
        vm.stopPrank();
    }

    function test_noEventOnSetTeamWallet() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setTeamWallet ---");
        vm.prank(owner);
        token.setTeamWalletAddress(newWallet);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setTeamWallet");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setTeamWallet");
        }
    }

    function test_noEventOnSetMarketingWallet() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setMarketingWallet ---");
        vm.prank(owner);
        token.setMarketingWalletAddress(newWallet);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setMarketingWallet");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setMarketingWallet");
        }
    }

    function test_noEventOnSetSwapEnabled() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setSwapAndLiquifyEnabled ---");
        vm.prank(owner);
        token.setSwapAndLiquifyEnabled(true);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setSwapAndLiquifyEnabled");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setSwapAndLiquifyEnabled");
        }
    }

    function test_noEventOnSetKillBlock() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setKillBlock ---");
        vm.prank(owner);
        token.setKillBlock(100);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setKillBlock");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setKillBlock");
        }
    }

    function test_noEventOnSetSwapLimitOnly() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setSwapAndLiquifyByLimitOnly ---");
        vm.prank(owner);
        token.setSwapAndLiquifyByLimitOnly(true);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setSwapAndLiquifyByLimitOnly");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setSwapAndLiquifyByLimitOnly");
        }
    }
    
    function test_noEventOnSetWalletLimit() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setWalletLimit ---");
        vm.prank(owner);
        token.setWalletLimit(1e18);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setWalletLimit");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setWalletLimit");
        }
    }

    function test_noEventOnSetTxLimitExempt() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setIsTxLimitExempt ---");
        vm.prank(owner);
        token.setIsTxLimitExempt(user, true);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setIsTxLimitExempt");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setIsTxLimitExempt");
        }
    }

    function test_noEventOnSetWalletLimitExempt() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setIsWalletLimitExempt ---");
        vm.prank(owner);
        token.setIsWalletLimitExempt(user, true);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setIsWalletLimitExempt");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setIsWalletLimitExempt");
        }
    }

    function test_noEventOnSetBuyTaxes() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setBuyTaxes ---");
        vm.prank(owner);
        token.setBuyTaxes(1, 1, 1);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setBuyTaxes");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setBuyTaxes");
        }
    }
    
    function test_noEventOnSetSellTaxes() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setSellTaxes ---");
        vm.prank(owner);
        token.setSellTaxes(1, 1, 1);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setSellTaxes");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setSellTaxes");
        }
    }

    function test_noEventOnSetDistributionSettings() public {
        console.log("--- BEFORE-Trigger Event Record ---");
        vm.recordLogs();

        console.log("--- Trigger setDistributionSettings ---");
        vm.prank(owner);
        token.setDistributionSettings(30, 30, 40);

        console.log("--- AFTER-Trigger Event Check ---");
        Vm.Log[] memory logs = vm.getRecordedLogs();
        if (logs.length == 0) {
            console.log("Vulnerability Exists: No event emitted for setDistributionSettings");
        } else {
            console.log("Vulnerability not Exist: Event emitted for setDistributionSettings");
        }
    }
}

// Mock Factory
contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }
}

// Mock Router
contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
}