// SPDX-License-Identifier: MIT
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KOFATOKEN.sol";

contract KOFAFeeTest is Test {
    KOFATOKEN token;
    address owner = address(this);

    // Mainnet/BSC router hardcoded in the KOFA token constructor
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    // Fake backing addresses used only to satisfy the constructor's external calls
    address constant MOCK_FACTORY = address(0xFAC7012);
    address constant MOCK_PAIR    = address(0xFA19);
    address constant MOCK_WETH    = address(0x7E7);

    function setUp() public {
        // 1) Ensure the hardcoded router (and the fake factory) have *some* bytecode,
        //    otherwise Solidity 0.7.x reverts with "call to non-contract address".
        vm.etch(PANCAKE_ROUTER, hex"00");
        vm.etch(MOCK_FACTORY, hex"00");
        vm.etch(MOCK_PAIR, hex"00");

        // 2) Mock the router accessors the token constructor uses.
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );

        // 3) The constructor calls factory.createPair(address(this), WETH).
        //    We must know the token address in advance, so compute the CREATE address
        //    of the token that this test contract is about to deploy.
        address predictedToken =
            vm.computeCreateAddress(address(this), vm.getNonce(address(this)));

        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature(
                "createPair(address,address)",
                predictedToken,
                MOCK_WETH
            ),
            abi.encode(MOCK_PAIR)
        );

        // 4) Now the constructor's external dependencies resolve cleanly.
        token = new KOFATOKEN();
    }

    function test_MarketingFeeExceedsLimit() public {
        console.log("--- BEFORE-Trigger State Snapshot ---");
        uint256 marketingFeeBefore = token.marketingFee();
        uint256 totalFeesBefore = token.totalFees();
        console.log("marketingFee before:", marketingFeeBefore);
        console.log("totalFees before:", totalFeesBefore);

        console.log("--- Trigger setMarketingFee(100) ---");
        (bool success, ) = address(token).call(
            abi.encodeWithSignature("setMarketingFee(uint256)", uint256(100))
        );
        console.log("setMarketingFee call success:", success);

        console.log("--- AFTER-Trigger State Snapshot ---");
        uint256 marketingFeeAfter = token.marketingFee();
        uint256 totalFeesAfter = token.totalFees();
        console.log("marketingFee after:", marketingFeeAfter);
        console.log("totalFees after:", totalFeesAfter);

        bool marketingFeeChanged = marketingFeeAfter != marketingFeeBefore;
        bool totalFeesChanged = totalFeesAfter != totalFeesBefore;
        bool marketingFeeSetTo100 = marketingFeeAfter == 100;
        bool stateChanged = marketingFeeChanged || totalFeesChanged;

        console.log("marketingFee changed:", marketingFeeChanged);
        console.log("totalFees changed:", totalFeesChanged);
        console.log("marketingFee equals 100:", marketingFeeSetTo100);
        console.log("state changed:", stateChanged);

        if (success && marketingFeeSetTo100 && stateChanged) {
            console.log("Vulnerability Exists: setMarketingFee(100) succeeded and changed marketingFee/totalFees state without an upper-bound check");
        } else {
            console.log("Vulnerability not Exist: setMarketingFee(100) did not successfully change state to marketingFee = 100");
        }
    }
}