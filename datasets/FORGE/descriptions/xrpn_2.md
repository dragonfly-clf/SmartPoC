#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L711,L627,L57 and 2 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L711,L627,L57 and 2 more|

```
rescueToken
tradingStatus
transferOwnership

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

