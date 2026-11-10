#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L693,L585,L572 and 10 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L693,L585,L572 and 10 more|

```
mint
decreaseAllowance
increaseAllowance

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

