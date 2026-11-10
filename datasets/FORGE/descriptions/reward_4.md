#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L352,365,370,396,400,404,781,962

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L352,365,370,396,400,404,781,962|

```
setPairAddress
isOverLiquified
decimals
symbol
name
transferOwnership
renounceOwnership
owner

```

##### Recommendation

Use the external attribute for functions never called from the contract


-----

