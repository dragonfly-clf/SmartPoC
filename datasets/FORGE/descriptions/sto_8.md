#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L478

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L478|

```
unitBalance = deltaBalance / (denominator - sellTaxes.liquidity)

```

##### Recommendation

The multiplications should be prior to the divisions.


-----

