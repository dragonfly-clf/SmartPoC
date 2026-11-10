#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L425,433,802,806,836,890,897,905,922,929,948,971,995,1018,1038

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L425,433,802,806,836,890,897,905,922,929,948,971,995,1018,1038|

```
decreaseAllowance
increaseAllowance
transferFrom
approve
transfer
totalSupply
decimals
symbol
name

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

