#### IDI - Immutable Declaration Improvement

**Criticality** Minor / Informative

**Location** PepeEconomyToken.sol#L584,585,589,590,592

**Status** Unresolved

#### Description

The contract is using variables that initialize them only in the constructor. The other

functions are not mutating the variables. These variables are not defined as `immutable .`
```
 uniswapV2Router
 uniswapV2Pair
 marketingFeeOnBuy
 marketingFeeOnSell
 marketingWallet

#### Recommendation

```
By declaring a variable as immutable, the Solidity compiler is able to make certain

optimizations. This can reduce the amount of storage and computation required by the

contract, and make it more gas-efficient.


-----

