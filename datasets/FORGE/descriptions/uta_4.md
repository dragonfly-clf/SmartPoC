#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L532,551

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L532,551|

```
tax = newTax
maxSellAmount = _maxSell

```

##### Recommendation

Emit an event for critical parameter changes.


-----

