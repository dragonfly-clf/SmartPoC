#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1164,1170

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1164,1170|


maxBuy = _max
maxSell = _max


##### Recommendation

Emit an event for critical parameter changes.


-----

