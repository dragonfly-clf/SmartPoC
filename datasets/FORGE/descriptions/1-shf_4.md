#### BM - Buyback Misleading

**Criticality** minor / informative

**Location** contract.sol#L410

**Status** Unresolved

##### Description

According to the buyback definition, a buyback is when a token purchases its own
shares in the market. The address 0x14940169E2Db1595CDD3CACd30DECC5bbB4d9f19
does not beloge to the contract address 0x9f59e79127fad40bbc26c1ec6578d345af40bd1f.
As a result the buyback fees are liquidated to buyback the

0x14940169E2Db1595CDD3CACd30DECC5bbB4d9f19 instead of the

0x14940169E2Db1595CDD3CACd30DECC5bbB4d9f19.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L410|
|Status|Unresolved|

```
buybackPath[0] = router.WETH();
buybackPath[1] = address(0x14940169E2Db1595CDD3CACd30DECC5bbB4d9f19);
//
router.swapExactETHForTokensSupportingFeeOnTransferTokens{value:
amountBNBBuyback}(
  0,
  buybackPath,
  DEAD,
  block.timestamp
);

```

##### Recommendation

The contract should buyback its own token shares.


-----

