#### RC - Repetitive Calculations

**Criticality** Minor / Informative

**Location** BullMeerkatToken.sol#L755,756

**Status** Unresolved

#### Description

The contract contains segments with multiple occurrences of the same calculation being

performed. The calculation is repeated without utilizing a variable to store its result, which

leads to redundant code, hinders code readability, and increases gas consumption. Each

repetition of the calculation requires computational resources and can impact the

performance of the contract, especially if the calculation is resource-intensive.
```
 maxTxAmount = totalSupply / 100; // 1% of total supply
 maxWalletBalance = totalSupply / 100; // 1% of total supply

#### Recommendation

```
To address this finding and enhance the efficiency and maintainability of the contract, it is

recommended to refactor the code by assigning the calculation result to a variable once

and then utilizing that variable throughout the method. By storing the calculation result in a

variable, the contract eliminates the need for redundant calculations and optimizes code

execution.

Refactoring the code to assign the calculation result to a variable has several benefits. It

improves code readability by making the purpose and intent of the calculation explicit. It

also reduces code redundancy, making the method more concise, easier to maintain, and

gas effective. Additionally, by performing the calculation once and reusing the variable, the

contract improves performance by avoiding unnecessary computations


-----

