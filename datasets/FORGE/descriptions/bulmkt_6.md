#### RSW - Redundant Storage Writes

**Criticality** Minor / Informative

**Location** BullMeerkatToken.sol#L815,819

**Status** Unresolved

#### Description

The contract modifies the state of the following variables without checking if their current

value is the same as the one given as an argument. As a result, the contract performs

redundant storage writes, when the provided parameter matches the current state of the

variables, leading to unnecessary gas consumption and inefficiencies in contract execution.
```
 function setExcludeFromLimits(
   address account,
   bool excluded
 ) external onlyOwner {
   _isExcludedFromLimits[account] = excluded;
 }
 function enableTrading() external onlyOwner {
   tradingOpen = true;
 }

#### Recommendation

```
The team is advised to implement additional checks within to prevent redundant storage

writes when the provided argument matches the current state of the variables. By

incorporating statements to compare the new values with the existing values before

proceeding with any state modification, the contract can avoid unnecessary storage

operations, thereby optimizing gas usage.


-----

