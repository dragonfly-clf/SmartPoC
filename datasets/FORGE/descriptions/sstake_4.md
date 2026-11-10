#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L349,362,367,393,397,401,884,903

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L349,362,367,393,397,401,884,903|

```
setPairAddress
getLiquidityBacking
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

