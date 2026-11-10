#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L212,219,238,247,253,258,565,582,589,616,627,663,682,857

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L212,219,238,247,253,258,565,582,589,616,627,663,682,857|

```
burn
decreaseAllowance
increaseAllowance
approve
allowance
totalSupply
decimals
symbol
acceptOwnership

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

