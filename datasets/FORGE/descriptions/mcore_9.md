#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1174,L1170,L1122 and 13 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1174,L1170,L1122 and 13 more|

```
sellLimit = amountWithoutDecimals * 10 ** _decimals
buyLimit = amountWithoutDecimals * 10 ** _decimals
buyBackUpperLimit = buyBackLimit * 10 ** 18

```
...


##### Recommendation

Emit an event for critical parameter changes.