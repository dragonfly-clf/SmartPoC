#### IDI - Immutable Declaration Improvement

**Criticality** Minor / Informative

**Location** Token.sol#L57,58,60,62,64,65,66,69,70,71,74,75,76

**Status** Unresolved

#### Description

The contract declares state variables that their value is initialized once in the constructor

and are not modified afterwards. The `immutable` is a special declaration for this kind of

state variables that saves gas when it is defined.
```
 decimals
 totalSupply
 deflationPercent
 deflationTotal
 tax1Percent
 tax1Address
 tax1Total
 tax2Percent
 tax2Address
 tax2Total
 tax3Percent
 tax3Address
 ...

#### Recommendation

```
By declaring a variable as immutable, the Solidity compiler is able to make certain

optimizations. This can reduce the amount of storage and computation required by the

contract, and make it more gas-efficient.


-----

