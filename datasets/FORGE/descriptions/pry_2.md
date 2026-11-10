#### IDI - Immutable Declaration Improvement

**Criticality** Minor / Informative

**Location** contracts/Pry.sol#L1117,1118,1121,1122,1123,1125,1126,1127

**Status** Unresolved

#### Description

The contract declares state variables that their value is initialized once in the constructor

and are not modified afterwards. The `immutable` is a special declaration for this kind of

state variables that saves gas when it is defined.
```
 maxTransactionAmount
 maxWallet
 buyDistroFee
 buyLiquidityFee
 buyTotalFees
 sellDistroFee
 sellLiquidityFee
 sellTotalFees

#### Recommendation

```
By declaring a variable as immutable, the Solidity compiler is able to make certain

optimizations. This can reduce the amount of storage and computation required by the

contract, and make it more gas-efficient.


-----

