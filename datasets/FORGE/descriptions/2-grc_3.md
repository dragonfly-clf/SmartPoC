#### RSW - Redundant Storage Writes

**Criticality** Minor / Informative

**Location** GlobalReserveCoin.sol#L883,901,1044,1045.1107,1161,1172,1183,1193

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract modifies the state of some variables without checking if the current state of

these variables is the same as the one given as an argument. As a result, the contract

performs redundant storage writes.
```
 No_Fee_Transfers = true_or_false;
 _isExcludedFromRewards[Wallet_Address] = true_or_false;
 _isPair[Wallet_Address] = true_or_false;
 _isLimitExempt[Wallet_Address] = true_or_false;
 swapAndLiquifyEnabled = true_or_false;
 ...

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it.


-----

