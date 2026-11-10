#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L663,692,668,697

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L663,692,668,697|
|Status|Unresolved|


coolDownTime = time * 1
maxBuyLimit = maxBuy * 10 ** decimals()
swapTokensAtAmount = amount * 10 ** _decimals
maxWalletLimit = amount * 10 ** decimals()


##### Recommendation

Emit an event for critical parameter changes.


-----

