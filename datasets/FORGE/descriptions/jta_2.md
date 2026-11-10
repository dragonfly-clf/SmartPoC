#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L952,L129,L116 and 1 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L952,L129,L116 and 1 more|

```
tradingStatus
transferOwnership
unauthorize

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

