#### RSD - Redundant Swap Duplication

**Criticality** Minor / Informative

**Location** KARMA.sol#L771

**Status** Unresolved

#### Description

The contract contains multiple swap methods that individually perform token swaps and

transfer promotional amounts to specific addresses and features. This redundant

duplication of code introduces unnecessary complexity and increases dramatically the gas

consumption. By consolidating these operations into a single swap method, the contract

can achieve better code readability, reduce gas costs, and improve overall efficiency.
```
 if(liquidityShare > 0) {
   uint256 liquidityTokens = (contractTokenBalance *
 liquidityShare) / totalShare;
   swapAndLiquify(liquidityTokens);
 }
 if(marketingShare > 0) {
   uint256 marketingTokens = (contractTokenBalance *
 marketingShare) / totalShare;
   swapAndSendMarketing(marketingTokens);
 }

#### Recommendation

```
A more optimized approach could be adopted to perform the token swap operation once

for the total amount of tokens and distribute the proportional amounts to the corresponding

addresses, eliminating the need for separate swaps.


-----

