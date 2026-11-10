#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1174,L1170,L1166 and 2 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1174,L1170,L1166 and 2 more|

```
maxWalletAmount = value * 10 ** _decimals
maxSellAmount = value * 10 ** _decimals
maxBuyAmount = value * 10 ** _decimals

```
...


##### Recommendation

Emit an event for critical parameter changes.