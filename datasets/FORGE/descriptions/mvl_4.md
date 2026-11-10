#### L08 - Tautology or Contradiction

**Criticality** minor

**Location** contract.sol#L991,1276,1281

##### Description

Detects expressions that are tautologies or contradictions. For instance, an uint
variable will always be greater than or equal to zero.

|Criticality|minor|
|---|---|
|Location|contract.sol#L991,1276,1281|

```
require(bool,string)(liquidityFeeBps >= 0 && liquidityFeeBps <= 10 ** 4,Invalid
bps)
require(bool,string)(taxFeeBps >= 0 && taxFeeBps <= 10 ** 4,Invalid bps)
require(bool,string)(taxFeeBps_ >= 0 && taxFeeBps_ <= 10 ** 4,Invalid tax fee)
require(bool,string)(charityFeeBps_ >= 0 && charityFeeBps_ <= 10 ** 4,Invalid
charity fee)
require(bool,string)(liquidityFeeBps_ >= 0 && liquidityFeeBps_ <= 10 **
4,Invalid liquidity fee)

```

##### Recommendation

Fix the incorrect comparison by changing the value type or the comparison.

