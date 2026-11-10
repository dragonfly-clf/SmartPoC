#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L154,158,162,249,258,263,290,294,298

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L154,158,162,249,258,263,290,294,298|

```
renounceWhitelisted
removeWhitelisted
addWhitelisted
transferOwnership
renounceOwnership
owner
decimals
symbol
name

```

##### Recommendation

Use the external attribute for functions never called from the contract.


-----

