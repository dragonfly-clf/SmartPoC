#### PVC - Price Volatility Concern

**Criticality** Minor / Informative

**Location** SpotPlayArena.sol#L727SpotPlayArena.sol#L773

**Status** Unresolved

#### Description

The contract accumulates tokens from the taxes to swap them for ETH. The contract has a

`swapEnabled` flag that can be toggled on and off from the owner using the

`setSwapEnabled` function. When `swapEnabled` is disabled, the contract starts to

accumulate tokens in its balance. If `swapEnabled` is later enabled, the contract will

swap all of its token balances at once meaning that a huge amount of tokens would be

swapped.

The swap condition also checks whether the sum of `_totalFeesOnBuy` and

`_totalFeesOnSell` is greater than zero. If the contract owner uses the

`updateBuyFees` and `updateSellFees` functions to set these fees to zero, the swap

will never occur. This could lead to an indefinite accumulation of tokens in the contract's

balance, until the contract owner resets the fees above zero.

Also the contract accumulates tokens from the taxes to swap them for ETH. The variable

`swapTokensAtAmount` sets a threshold where the contract will trigger the swap

functionality. If the variable is set to a big number, then the contract will swap a huge

amount of tokens for ETH.

It is important to note that the price of the token representing it, can be highly volatile. This

means that the value of a price volatility swap involving Ether could fluctuate significantly at

the triggered point, potentially leading to significant price volatility for the parties involved.


-----

#### Recommendation

The contract could ensure that it will not sell more than a reasonable amount of tokens in a

single transaction. We recommend implementing a mechanism to limit the number of

tokens that can be swapped at once. This could be a fixed limit or a percentage of the total

token supply or the contract's token balance. Hence, the contract will guarantee that it

cannot accumulate a huge amount of tokens in order to sell them.


-----

