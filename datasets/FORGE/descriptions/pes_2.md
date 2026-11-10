#### FRV - Fee Restoration Vulnerability

**Criticality** Minor / Informative

**Location** PEPESMOKING.sol#L930,945,1151

**Status** Unresolved

#### Description

The contract demonstrates a potential vulnerability upon removing and restoring the fees.

This vulnerability can occur when the fees have been set to zero. During a transaction, if the

fees have been set to zero, then both remove fees and restore fees functions will be

executed. The remove fees function is executed to temporarily remove the fees, ensuring

the sender is not taxed during the transfer. However, the function prematurely returns

without setting the variables that hold the previous fee values.

As a result, when the subsequent restore fees function is called after the transfer, it restores

the fees to their previous values. However, since the previous fee values were not properly

set to zero, there is a risk that the fees will retain their non-zero values from before the fees

were removed. This can lead to unintended consequences, potentially causing incorrect fee

calculations or unexpected behavior within the contract.


-----

-----

#### Recommendation

The team is advised to modify the remove fees function to ensure that the previous fee

values are correctly set to zero, regardless of their initial values. A recommended approach

would be to remove the early return when both fees are zero.


-----

