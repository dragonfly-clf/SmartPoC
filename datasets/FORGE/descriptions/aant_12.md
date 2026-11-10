#### L08 - Tautology or Contradiction

**Criticality** minor

**Location** contract.sol#L1263,1268,1273

##### Description

Detects expressions that are tautologies or contradictions. For instance, an uint
variable will always be greater than or equal to zero.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1263,1268,1273|

```
require(bool,string)(newFee >= 0 && newFee <= 15,AANT: ETH/BNB Rewards tax must
be between 0 and 15)
require(bool,string)(newFee >= 0 && newFee <= 10,AANT: Liquidity tax must be
between 0 and 10)
require(bool,string)(newFee >= 0 && newFee <= 10,AANT: Expenses tax must be
between 0 and 10)

```

##### Recommendation

Fix the incorrect comparison by changing the value type or the comparison.


-----

