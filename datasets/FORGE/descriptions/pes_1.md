#### RSD - Redundant Swap Duplication

**Criticality** Minor / Informative

**Location** PEPESMOKING.sol#L1003

**Status** Unresolved

#### Description

The contract contains multiple swap methods that individually perform token swaps and

transfer promotional amounts to specific addresses and features. This redundant

duplication of code introduces unnecessary complexity and increases dramatically the gas

consumption. By consolidating these operations into a single swap method, the contract

can achieve better code readability, reduce gas costs, and improve overall efficiency.
```
 function swapAndLiquify(uint256 contractTokenBalance) private
 lockTheSwap {
      uint256 liquidityTokens =
 contractTokenBalance.mul(_liquidityFee).div(_liquidityFee.add(_marketing
 Fee));
      uint256 half = liquidityTokens.div(2);
      uint256 otherHalf = liquidityTokens.sub(half);
      ...
      swapTokensForEth(half);
      ...
      swapTokensForEth(contractTokenBalance.sub(liquidityTokens));
      ...
   }

#### Recommendation

```
A more optimized approach could be adopted to perform the token swap operation once

for the total amount of tokens and distribute the proportional amounts to the corresponding

addresses, eliminating the need for separate swaps.


-----

