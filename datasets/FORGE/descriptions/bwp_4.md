#### BSB - Buyback Sufficient Balance

**Criticality** minor / informative

**Location** contract.sol#L1134

**Status** Unresolved

##### Description

The contract should check if the contract native currency balance is sufficient to
proceed with the swapExactETHForTokensSupportingFeeOnTransferTokens. In case
of something unexpected produced by the bnbForBuyBack tracking, the contract
should not allow the swap execution.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1134|
|Status|Unresolved|

```
function _buyBack() internal swapping {
  (uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
  if (lqBNBAmount.mul(lqTokenAmount) == 0 || bnbForBuyBack == 0) {
    return;
  }
  uint256 amount = bnbForBuyBack;
  address[] memory path = new address[](2);
  path[0] = router.WETH();
  path[1] = address(this);
  router.swapExactETHForTokensSupportingFeeOnTransferTokens{
    value: amount
  }(0, path, buyBackReceiver, block.timestamp);
  bnbForBuyBack = 0;
}

```

##### Recommendation

The contract could check if the contract’s native balance is more than the
bnbForBuyBack in order to proceed with the swap.


-----

