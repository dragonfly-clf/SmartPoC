#### RFC - Redundant Fees Calculation

**Criticality** Minor / Informative

**Location** MitaoCat.sol#L445

**Status** Unresolved

#### Description

The `sellTotalFees` are always equal to the `sellFees.operationsFee . As a result,`

the expression `sellFee.operationsFee / sellTotalFees` will always equal 1. The

same applies to the buy variable.
```
 sellFees memory sellFee = _sellFees[currentTID];
 fees = amount * sellTotalFees / 100;
 tokensForOperations += fees * sellFee.operationsFee /
 sellTotalFees;
 ...
 buyFees memory buyFee = _buyFees[currentTID];
 fees = amount * buyTotalFees / 100;
 tokensForOperations += fees * buyFee.operationsFee / buyTotalFees;

#### Recommendation

```
The team is advised to remove the division of the fee since it always produces multiplication

with the number one.


-----

