#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L802,806,810,814,824,844,854,871,884,1022 and 7 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L802,806,810,814,824,844,854,871,884,1022 and 7 more|

```
burnFrom
burn
vault
transferOwnership
renounceOwnership
owner
nonces
permit
decreaseAllowance

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

