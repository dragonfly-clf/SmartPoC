#### RSW - Redundant Storage Writes

**Criticality** Minor / Informative

**Location** MineBNB.sol#L564,644,648,652

**Status** Unresolved

#### Description

The contract modifies the state of the following variables without checking if their current

value is the same as the one given as an argument. As a result, the contract performs

redundant storage writes, when the provided parameter matches the current state of the

variables, leading to unnecessary gas consumption and inefficiencies in contract execution.
```
 tradingOpen = _status;
 isFeeExempt[holder] = exempt;
 isTxLimitExempt[holder] = exempt;
 isTimelockExempt[holder] = exempt;

#### Recommendation

```
The team is advised to implement additional checks within to prevent redundant storage

writes when the provided argument matches the current state of the variables. By

incorporating statements to compare the new values with the existing values before

proceeding with any state modification, the contract can avoid unnecessary storage

operations, thereby optimizing gas usage.


-----

