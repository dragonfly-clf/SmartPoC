#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L968,985,1289,1555

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L968,985,1289,1555|
|Status|Unresolved|

```
NFTPrice = nftPrice
NFTsCanBeSold = nums
presaleNFTPrice = _price
buyFee = _buyFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

