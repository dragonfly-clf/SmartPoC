#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L637,664,683,688

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L637,664,683,688|


maxWalletLimit = amount * 10 ** decimals()
maxBuyLimit = maxBuy * 10 ** decimals()
swapTokensAtAmount = amount * 10 ** _decimals
coolDownTime = time * 1


##### Recommendation

Emit an event for critical parameter changes.


-----

