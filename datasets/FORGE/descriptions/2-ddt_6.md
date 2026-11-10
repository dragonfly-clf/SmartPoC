#### L07 - Missing Events Arithmetic

|Criticality|minor|
|---|---|
|Location|DiamondDexToken.sol#L1168,1172,1176,1180,1195|
|Status|unresolved|


##### Description


Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.


##### Recommendation


Emit an event for critical parameter changes.


-----

