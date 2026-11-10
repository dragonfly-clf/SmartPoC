#### L07 - Missing Events Arithmetic

###### Criticality minor

 Location contract.sol#L2159,2168,2187,2190

##### Description

###### Detected missing events for critical arithmetic parameters. There are functions that have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2159,2168,2187,2190|

```
marketFee = marketfee
burnFee = burnfee
_minimumTokensBeforeSwap = newLimit
killBlockNum = num

```

##### Recommendation

###### Emit an event for critical parameter changes.


-----

