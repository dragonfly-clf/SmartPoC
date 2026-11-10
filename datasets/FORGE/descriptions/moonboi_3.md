#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1469,L1438,L1426 and 30 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1469,L1438,L1426 and 30 more|

```
TeamRemoveRemainingBNB
TeamRemoveLiquidity
TeamReleaseLiquidity

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

