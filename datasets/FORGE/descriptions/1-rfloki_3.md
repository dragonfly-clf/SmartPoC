#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1116,L1108,L1070 and 19 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1116,L1108,L1070 and 19 more|

```
disableTax
enableTax
removeExclude

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

