#### PVC - Price Volatility Concern

**Criticality** Minor / Informative

**Location** HXPE.sol#L715

**Status** Unresolved

#### Description

The contract accumulates tokens from the taxes to swap them for ETH. The variable

`swapTokensAtAmount` sets a threshold where the contract will trigger the swap

functionality. If the variable is set to a big number, then the contract will swap a huge

amount of tokens for ETH.

It is important to note that the price of the token representing it, can be highly volatile. This

means that the value of a price volatility swap involving Ether could fluctuate significantly at

the triggered point, potentially leading to significant price volatility for the parties involved.
```
 bool overMinTokenBalance = contractTokenBalance >=
 swapTokensAtAmount;

#### Recommendation

```
The contract could ensure that it will not sell more than a reasonable amount of tokens in a

single transaction. A suggested implementation could check that the maximum amount

should be less than a fixed percentage of the total supply. Hence, the contract will

guarantee that it cannot accumulate a huge amount of tokens in order to sell them.


-----

