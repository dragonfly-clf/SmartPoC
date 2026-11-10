// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AsunaHentai.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xc0de);
    }
    
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract MockFactory {
    function createPair(address tokenA, address tokenB) external pure returns (address) {
        return address(0xdead);
    }
}

contract AsunaHentaiTest is Test {
    AsunaHentai token;
    address owner = address(this);
    
    function _getBytecode(address addr) private view returns (bytes memory) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        bytes memory code = new bytes(size);
        assembly {
            extcodecopy(addr, add(code, 0x20), 0, size)
        }
        return code;
    }

    function setUp() public {
        // Mock router at expected address
        address ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        MockRouter mockRouter = new MockRouter();
        bytes memory routerCode = _getBytecode(address(mockRouter));
        vm.etch(ROUTER, routerCode);

        // Mock factory at address returned by MockRouter
        address FACTORY_ADDR = address(0xc0de);
        MockFactory mockFactory = new MockFactory();
        bytes memory factoryCode = _getBytecode(address(mockFactory));
        vm.etch(FACTORY_ADDR, factoryCode);

        // Deploy token
        token = new AsunaHentai();
    }

    // Test duplicate additions to antibot whitelist
    function test_antibot_whitelist_duplicate_adds() public {
        console.log("----- TEST: Duplicate add to antibot whitelist -----");
        // Enable antibot mode
        token.turnOnAntibotMode();

        // Setup whitelist addresses
        address[] memory toAdd = new address[](1);
        toAdd[0] = address(0x123);
        address[] memory empty = new address[](0);

        console.log("--- BEFORE-Trigger (initial add) ---");
        token.setAntibotModeWhitelist(toAdd, empty);
        console.log("Completed initial add to antibot whitelist");

        console.log("--- Trigger: Attempt duplicate add ---");
        bool duplicateAddSucceeded;
        try token.setAntibotModeWhitelist(toAdd, empty) {
            duplicateAddSucceeded = true;
            console.log("Result: Duplicate add succeeded without revert");
        } catch {
            duplicateAddSucceeded = false;
            console.log("Result: Duplicate add reverted");
        }

        console.log("--- Final Verdict ---");
        if (duplicateAddSucceeded) {
            console.log("Vulnerability Exists: Duplicate additions to antibot whitelist are allowed");
        } else {
            console.log("Vulnerability not Exist: Contract properly reverts on whitelist duplicates");
        }
    }

    // Test duplicate additions to AMM pairs
    function test_amm_pairs_duplicate_adds() public {
        console.log("----- TEST: Duplicate add to AMM pairs -----");
        address somePair = address(0x456);
        
        console.log("--- BEFORE-Trigger (initial add) ---");
        token.manageAmmPairs(somePair, true);
        console.log("Completed initial add to AMM pairs");

        console.log("--- Trigger: Attempt duplicate add ---");
        bool duplicateAddSucceeded;
        try token.manageAmmPairs(somePair, true) {
            duplicateAddSucceeded = true;
            console.log("Result: Duplicate add succeeded without revert");
        } catch {
            duplicateAddSucceeded = false;
            console.log("Result: Duplicate add reverted");
        }

        console.log("--- Final Verdict ---");
        if (duplicateAddSucceeded) {
            console.log("Vulnerability Exists: Duplicate additions to AMM pairs are allowed");
        } else {
            console.log("Vulnerability not Exist: Contract properly reverts on AMM pair duplicates");
        }
    }
}