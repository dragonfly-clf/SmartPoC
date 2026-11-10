#### PVC - Price Volatility Concern

**Criticality** Minor / Informative

**Location** Karma.sol#L631

**Status** Renounced

#### Description

The contract accumulates tokens from the taxes to swap them for ETH. The variables

`smallSwapThreshold` and `largeSwapThreshold` set a threshold where the

contract will trigger the swap functionality. If the variables are set to a big number, then the

contract will swap a huge amount of tokens for ETH.

It is important to note that the price of the token representing it, can be highly volatile. This

means that the value of a price volatility swap involving Ether could fluctuate significantly at

the triggered point, potentially leading to significant price volatility for the parties involved.
```
 function setSwapBackSettings(
   bool _enabled,
   uint256 _amountS,
   uint256 _amountL,
   bool _alternate
 ) external onlyOwner {
   alternateSwaps = _alternate;
   claimingFees = _enabled;
   smallSwapThreshold = _amountS;
   largeSwapThreshold = _amountL;
   swapThreshold = smallSwapThreshold;
 }

#### Recommendation

```
The contract could ensure that it will not sell more than a reasonable amount of tokens in a

single transaction. A suggested implementation could check that the maximum amount

should be less than a fixed percentage of the total supply. Hence, the contract will

guarantee that it cannot accumulate a huge amount of tokens in order to sell them.


-----

#### Team Update


The contract's ownership has been renounced. The information regarding the transaction


can be accessed through the following link:


[https://bscscan.com/tx/0x5d7c25dffae6304ff73e00f334feb8d419f22b15a48a022f18d51a49](https://bscscan.com/tx/0x5d7c25dffae6304ff73e00f334feb8d419f22b15a48a022f18d51a490d13b04f)


[0d13b04f.](https://bscscan.com/tx/0x5d7c25dffae6304ff73e00f334feb8d419f22b15a48a022f18d51a490d13b04f)


-----

