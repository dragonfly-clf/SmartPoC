#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L2184,2202,2193

###### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2184,2202,2193|


buyTokenRewardsFee = rewardsFee
sellTokenRewardsFee = rewardsFee
swapTokensAtAmount = amount


###### Recommendation

Emit an event for critical parameter changes.


-----

