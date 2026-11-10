#### IDI - Immutable Declaration Improvement

**Criticality** Minor / Informative

**Location** contracts/GODFATHER.sol#L247

**Status** Unresolved

#### Description

The contract declares state variables that their value is initialized once in the constructor

and are not modified afterwards. The `immutable` is a special declaration for this kind of

state variables that saves gas when it is defined.
```
 creator

#### Recommendation

```
By declaring a variable as immutable, the Solidity compiler is able to make certain

optimizations. This can reduce the amount of storage and computation required by the

contract, and make it more gas-efficient.


-----

