#### IDI - Immutable Declaration Improvement

**Criticality** Minor / Informative

**Location** ZangAi.sol#L410,412,416,417,419,420,422,423,425,426

**Status** Unresolved

#### Description

The contract declares state variables that their value is initialized once in the constructor

and are not modified afterwards. The `immutable` is a special declaration for this kind of

state variables that saves gas when it is defined.
```
 uniswapV2Pair
 uniswapV2Router
 taxFeeonBuy
 taxFeeonSell
 liquidityFeeonBuy
 liquidityFeeonSell
 marketingFeeonBuy
 marketingFeeonSell
 totalBuyFees
 totalSellFees

#### Recommendation

```
By declaring a variable as immutable, the Solidity compiler is able to make certain

optimizations. This can reduce the amount of storage and computation required by the

contract, and make it more gas-efficient.


-----

