// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaCashWallet.sol";

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;

    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    address public immutable pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockWETH {}

contract RevertingContract {
    function failFunction() public pure {
        revert("Custom error message");
    }
}

contract FunctionCallVulnerabilityTest is Test {
    MetaCashWallet public token;
    RevertingContract public reverting;
    address private owner = address(0x1);
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Setup router mock
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory(address(0x123));
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Overwrite router address with mock
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);

        vm.startPrank(owner);
        token = new MetaCashWallet();
        reverting = new RevertingContract();
        vm.stopPrank();
    }

    function testFunctionCallErrorPropagation() public {
        console.log("--- BEFORE-Trigger Call ---");
        // Log before call state (no state to validate)
        console.log("Preparing calls...");
        bytes memory data = abi.encodeWithSignature("failFunction()");

        console.log("--- Trigger Call ---");
        // Execute call through the wallet
        (bool callSuccess, bytes memory callErr) = address(token).call(
            abi.encodeWithSignature(
                "functionCall(address,bytes)", 
                address(reverting), 
                data
            )
        );
        console.log("Executed call through wallet: %s", callSuccess ? "true (unexpected)" : "false (expected)");

        // Make direct call for comparison
        (bool directSuccess, bytes memory directErr) = address(reverting).call(data);
        console.log("Direct call to reverting contract: %s", directSuccess ? "true (unexpected)" : "false (expected)");
        
        console.log("--- AFTER-Trigger Call ---");
        console.log("Wallet call error: %s", string(callErr));
        console.log("Direct call error: %s", string(directErr));
        
        // Compare error messages
        bool sameError = !callSuccess && !directSuccess && 
            keccak256(callErr) == keccak256(directErr) &&
            keccak256(directErr) == keccak256(abi.encodePacked("Custom error message"));
        
        // Final vulnerability verdict
        if (sameError) {
            console.log("Vulnerability Exists: Error propagation matches between direct call and wallet call");
        } else {
            console.log("Vulnerability not Exist: Error propagation mismatch or unexpected success");
        }
    }
}