#### IDI - Immutable Declaration Improvement

**Criticality** Minor / Informative

**Location** LiquidityGeneratorToken.sol#L997,998,999,1001,1010,1016,1022,1026

**Status** Unresolved

#### Description

The contract declares state variables that their value is initialized once in the constructor

and are not modified afterwards. The `immutable` is a special declaration for this kind of

state variables that saves gas when it is defined.
```
 _decimals
 _tTotal
 _charityAddress
 swapAndLiquifyEnabled
 uniswapV2Pair
 uniswapV2Router

#### Recommendation

```
By declaring a variable as immutable, the Solidity compiler is able to make certain

optimizations. This can reduce the amount of storage and computation required by the

contract, and make it more gas-efficient.


-----

