#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L776,319,748,781,743

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L776,319,748,781,743|
|Status|Unresolved|


maxBuyLimit = maxBuy * 10 ** decimals()
deadline = _deadline
swapTokensAtAmount = amount * 10 ** _decimals
maxWalletLimit = amount * 10 ** decimals()
coolDownTime = time * 1


##### Recommendation

Emit an event for critical parameter changes.


-----

