#### L13 - Divide before Multiply Operation

**Criticality** minor / informative

**Location** contract.sol#L763,950

**Status** Unresolved

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L763,950|
|Status|Unresolved|


_rOwned[_msgSender()] = _rTotal.div(10 ** 2).mul(90)
_rOwned[_moonJPAddress] = _rTotal.div(10 ** 2).mul(10)
_jpPortion = _rTotal.div(10 ** 2).mul(10).mul(_jpRatio).div(10 ** 3)


##### Recommendation

The multiplications should be prior to the divisions.


-----

