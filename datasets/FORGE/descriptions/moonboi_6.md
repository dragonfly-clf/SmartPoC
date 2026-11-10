#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1379,L1369,L1355 and 4 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1379,L1369,L1355 and 4 more|

```
balanceLimit = newBalanceLimit
marketingShare = newShare
_burnTax = burnTaxes

```
...


##### Recommendation

Emit an event for critical parameter changes.