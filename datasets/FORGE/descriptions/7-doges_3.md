#### MEM - Misleading Error Messages

**Criticality** Minor / Informative

**Location** DOGES_FARM_Token.sol#L858,867

**Status** Unresolved

#### Description

The contract is using misleading error messages.The `updateBuyFees` and

`updateSellFees` functions that are designed to update the fee values of

`_totalFeesOnBuy` and `_totalFeesOnSell` varriables respectively. Both functions

allow the owner to set the respective fees up to a maximum value of 10%. This is evident

from the condition `_marketingFeeOnBuy <= 10` and `_marketingFeeOnSell <=`
```
10 . However, the error message associated with this condition states, "Fees must be less

```
than 3%". These error messages do not accurately reflect the problem, making it difficult to

identify and fix the issue. As a result, the users will not be able to find the root cause of the

error.


-----

#### Recommendation

The team is suggested to provide a descriptive message to the errors. This message can be

used to provide additional context about the error that occurred or to explain why the

contract execution was halted. This can be useful for debugging and for providing more

information to users that interact with the contract.

Specifically, the team could consider updating the error message in both

`updateBuyFees` and `updateSellFees` functions to accurately reflect the actual fee

percentage allowed by the contract.


-----

