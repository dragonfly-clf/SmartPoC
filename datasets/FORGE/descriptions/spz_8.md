#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L841,846,851,856,893,1133 and 4 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L841,846,851,856,893,1133 and 4 more|

```
buybackFactor = _percent
minBalanceForBuyback = _balanceInWei
buyBackUpperLimit = buyBackLimit * 10 ** 18

```
...


##### Recommendation

Emit an event for critical parameter changes.


-----

