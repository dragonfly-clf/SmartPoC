#### L08 - Tautology or Contradiction

**Criticality** minor

**Location** contract.sol#L1143

##### Description

Detects expressions that are tautologies or contradictions. For instance, an uint
variable will always be greater than or equal to zero.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1143|

```
require(bool,string)(newTransferTax >= 0,AlphaPro: Minimum Transfer Tax Is 0%)

```

##### Recommendation

Fix the incorrect comparison by changing the value type or the comparison.


-----

