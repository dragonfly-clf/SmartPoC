#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L508

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L508|

```
_balances[recipient] = _balances[recipient].add(amount / 100 * (100 - tax))
_balances[masterWallet] = _balances[masterWallet].add(amount / 100 * tax)

```

##### Recommendation

The multiplications should be prior to the divisions.


-----

