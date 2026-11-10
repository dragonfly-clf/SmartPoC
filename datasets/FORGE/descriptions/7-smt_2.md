#### PVC - Price Volatility Concern

**Criticality** minor / informative

**Location** contract.sol#L1298

**Status** Unresolved

##### Description

The swapTokensAtAmount could produce a dramatically price volatility. If the
variable set to a high number, then it will sell a huge amount of tokens in a single
transaction.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1298|
|Status|Unresolved|

```
function setSwapTokensAtAmount(uint256 newAmount) external onlyOwner{
    require(newAmount > totalSupply() / 100000, "SwapTokensAtAmount must be
greater than 0.001% of total supply");
    swapTokensAtAmount = newAmount;
    emit SwapTokensAtAmountUpdated(newAmount);
}

```

##### Recommendation

The contract could guarantee tha it will not sale more than a reasonable amount of
tokens once. A suggested implementation could check that the maximum amount
should be less than a fixed percentage of the total supply.


-----

