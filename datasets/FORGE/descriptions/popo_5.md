#### IDI - Immutable Declaration Improvement

**Criticality** Minor / Informative

**Location** POPO.sol#L219,235

**Status** Unresolved

#### Description

The contract is using variables that initialize them only in the constructor. The other

functions are not mutating the variables. These variables are not defined as `immutable .`
```
 swapRouter
 lpPair

#### Recommendation

```
By declaring a variable as immutable, the Solidity compiler is able to make certain

optimizations. This can reduce the amount of storage and computation required by the

contract, and make it more gas-efficient.


-----

