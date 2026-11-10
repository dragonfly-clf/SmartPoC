#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L306,314,718,726,743,769,788,806,834,853,1033,1048,1358,1438,
1442,1446,1474,1478

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L306,314,718,726,743,769,788,806,834,853,1033,1048,1358,1438, 1442,1446,1474,1478|

```
setMinHolder
setClaimable
getRewardedByAddressAndToken
getRewardByAddressAndToken
viewTransferFee
withdrawAmountBNB
burnFrom
burn
decreaseAllowance

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

