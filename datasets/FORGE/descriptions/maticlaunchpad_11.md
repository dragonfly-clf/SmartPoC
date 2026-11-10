#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L845

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L845|

```
_price = _eth / sPrice

```

##### Recommendation

The multiplications should be prior to the divisions.