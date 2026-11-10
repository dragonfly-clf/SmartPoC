#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1202,L1180,L1174 and 2 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1202,L1180,L1174 and 2 more|

```
maxWalletTokens = 50000000000000 * 10 ** 18 * maxWalletPercent
extraSellFee = value
marketingFee = value

```
...


##### Recommendation

Emit an event for critical parameter changes.