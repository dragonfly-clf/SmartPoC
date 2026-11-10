#### PVC - Price Volatility Concern

**Criticality** minor / informative

**Location** contract.sol#L2188

**Status** Unresolved

##### Description

The swapTokensAtAmount could produce a dramatically price volatility. If the
variable set to a high number, then the contract will sell a huge amount of tokens in
a single transaction.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L2188|
|Status|Unresolved|

```
function setSwapTokensAtAmount(uint256 amount) public onlyOwner {
  swapTokensAtAmount = amount;
}

```

##### Recommendation

The contract could ensure that it will not sell more than a reasonable amount of
tokens once. A suggested implementation could check that the maximum amount
should be less than a fixed percentage of the total supply.


-----

