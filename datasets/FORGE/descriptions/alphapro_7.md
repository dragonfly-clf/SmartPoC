#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L573,569,565,534,1154,521,539

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L573,569,565,534,1154,521,539|

```
transferOwnership
owner
getLiquidityBacking
renounceOwnership
name
symbol
decimals

```

##### Recommendation

Use the external attribute for functions never called from the contract.


-----

