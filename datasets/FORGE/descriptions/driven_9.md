#### L13 - Divide before Multiply Operation

###### Criticality minor

 Location contract.sol#L2054

##### Description

###### Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2054|

```
_minimumTokensBeforeSwap = supply.div(1000) * 10 ** _decimals

```

##### Recommendation

###### The multiplications should be prior to the divisions.