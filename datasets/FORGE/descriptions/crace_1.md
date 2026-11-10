#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L711,L125,L104 and 1 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L711,L125,L104 and 1 more|

```
getUnpaidEarnings
transferOwnership
unauthorize

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

