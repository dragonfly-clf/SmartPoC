#### PVC - Price Volatility Concern

**Criticality** Minor / Informative

**Location** contracts/Twelve_Days_Of_Xmas.sol#L266

**Status** Unresolved

#### Description

The contract accumulates tokens from the taxes to swap them for ETH. The variable

`swapThreshold` sets a threshold where the contract will trigger the swap functionality.

The `swapThreshold` variable can be set up to `10%` of the total supply. As a result the

contract will swap a huge amount of tokens for ETH.

It is important to note that the price of the token representing it, can be highly volatile. This

means that the value of a price volatility swap involving Ether could fluctuate significantly at

the triggered point, potentially leading to significant price volatility for the parties involved.
```
 function swapBack() internal swapping {
   uint256 totalBNBFee = totalFee;
   uint256 amountToSwap = swapThreshold ;
   address[] memory path = new address[](2);
   path[0] = address(this);
   path[1] = WBNB;
   router.swapExactTokensForETHSupportingFeeOnTransferTokens(
   amountToSwap,
   0,
   path,
   address(this),
   block.timestamp
 );

#### Recommendation

```
The contract could ensure that it will not sell more than `2 %` of the total supply of tokens

in a single transaction. A suggested implementation could check that the maximum amount


-----

should be less than a fixed percentage of the exchange reserves. Hence, the contract will

guarantee that it cannot accumulate a huge amount of tokens in order to sell them.


-----

