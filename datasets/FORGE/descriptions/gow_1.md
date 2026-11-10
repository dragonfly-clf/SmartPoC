#### IDI - Immutable Declaration Improvement

**Criticality** Minor / Informative

**Location** BEP20Token.sol#L352,353,354

**Status** Unresolved

#### Description

The contract is using variables that initialize them only in the constructor. The other

functions are not mutating the variables. These variables are not defined as `immutable .`
```
 _name
 _symbol
 _decimals

#### Recommendation

```
By declaring a variable as immutable, the Solidity compiler is able to make certain

optimizations. This can reduce the amount of storage and computation required by the

contract, and make it more gas-efficient.


-----

