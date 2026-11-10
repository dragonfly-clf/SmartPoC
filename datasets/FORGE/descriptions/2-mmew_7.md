#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L722,726,730,734,738,750 and 7 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L722,726,730,734,738,750 and 7 more|

```
_lottoMinimumSpend = minimumSpend
_lottoThreshold = threshold
_lottoChance = chance

```
...


##### Recommendation

Emit an event for critical parameter changes.


-----

