#### L08 - Tautology or Contradiction

**Criticality** minor

**Location** contract.sol#L1288,1293,1298

##### Description

Detects expressions that are tautologies or contradictions. For instance, an uint
variable will always be greater than or equal to zero.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1288,1293,1298|

```
require(bool,string)(newFee >= 0 && newFee <= 15,SgtSHIB: ETH/BNB Rewards tax
must be between 0 and 15)
require(bool,string)(newFee >= 0 && newFee <= 10,SgtSHIB: Liquidity tax must be
between 0 and 10)
require(bool,string)(newFee >= 0 && newFee <= 10,SgtSHIB: Expenses tax must be
between 0 and 10)

```

##### Recommendation

Fix the incorrect comparison by changing the value type or the comparison.


-----

