#### L01 - Public Function could be Declared External

**Criticality** minor / informative

**Location** contract.sol#L904,911,918,947,977,1106,1125,1609,1614

**Status** Unresolved

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L904,911,918,947,977,1106,1125,1609,1614|
|Status|Unresolved|

```
totalSupply
decimals
symbol
allowance
transfer
increaseAllowance
decreaseAllowance
mint
burn

```

##### Recommendation

Use the external attribute for functions never called from the contract.


-----

