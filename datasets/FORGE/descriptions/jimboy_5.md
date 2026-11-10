#### PVC - Price Volatility Concern

**Criticality** Minor / Informative

**Location** JIMBOY.sol#L534

**Status** Renounced

#### Description

The contract accumulates tokens from the taxes to swap them for ETH. The variable

`_swapTokensAtAmount` sets a threshold where the contract will trigger the swap

functionality. If the variable is set to a big number, then the contract will swap a huge

amount of tokens for ETH.

It is important to note that the price of the token representing it, can be highly volatile. This

means that the value of a price volatility swap involving Ether could fluctuate significantly at

the triggered point, potentially leading to significant price volatility for the parties involved.
```
 function setMinSwapTokensThreshold(uint256 swapTokensAtAmount) public
 onlyOwner {
   _swapTokensAtAmount = swapTokensAtAmount;
 }

#### Recommendation

```
The contract could ensure that it will not sell more than a reasonable amount of tokens in a

single transaction. A suggested implementation could check that the maximum amount

should be less than a fixed percentage of the total supply. Hence, the contract will

guarantee that it cannot accumulate a huge amount of tokens in order to sell them.


#### Team Update


The contract's ownership has been renounced. The information regarding the transaction


can be accessed through the following link:


[https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a8](https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a82d0ac33fb2d)


[2d0ac33fb2d.](https://bscscan.com/tx/0xcc7516a17d7f5b99367b4a675a8666a3279a63133fd82c54b40a82d0ac33fb2d)


-----

