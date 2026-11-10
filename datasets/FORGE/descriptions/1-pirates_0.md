#### ST - Stops Transactions

**Criticality** critical

**Location** contract.sol#L1142,1173

**Status** Unresolved

##### Description

Users can be taxed up to 100% or prevented from sale if they sell during the first
day of their purchase.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1142,1173|
|Status|Unresolved|

```
if (!isBuy && enableEarlySellTax) {
  if (_holderFirstBuyTimestamp[from] != 0 && (_holderFirstBuyTimestamp[from]
+ (24 hours) >= block.timestamp)) {
    sellLiquidityFee = earlySellLiquidityFee;
    sellMarketingFee = earlySellMarketingFee;
    sellDevFee = earlySellDevFee;
    sellTotalFees = sellMarketingFee + sellLiquidityFee + sellDevFee;
  } else {
    sellLiquidityFee = 2;
    sellMarketingFee = 0;
    sellDevFee = 3;
    sellTotalFees = sellMarketingFee + sellLiquidityFee + sellDevFee;
  }
}

```

The contract owner can limit the transactions to one per block. Once disabled, it
cannot be reenabled.

```
require(_holderLastTransferTimestamp[tx.origin] < block.number, "_transfer::
Transfer Delay enabled. Only one purchase per block allowed.");

```

-----

##### Recommendation

The contract should remove the last transfer check, as it may cause a transaction to
fail. Additionally, the contract could embody a check for not allowing setting the
early sell taxes more than the allowed limit of 25%.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

