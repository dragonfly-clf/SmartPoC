#### UPA - Unexcluded Pinksale Address

**Criticality** Medium

**Location** MOLLARS.sol#L412

**Status** Unresolved

#### Description

The contract is designed with a fee mechanism that applies to each transaction. This

design, poses a significant obstacle for integration with platforms like Pinksale. Specifically,

for the creation of a launchpad on Pinksale, the Pinksale factory address must be exempted

from these transaction fees. Without this exemption, the creation of the pool on Pinksale will

be prevented.
```
     if (
        isFeeExempt[sender] ||
        isFeeExempt[recipient] ||
        (sender != pair && recipient != pair)
      ) {
        amountReceived = amount;
      } else {
        uint256 feeAmount;
        if (sender == pair) {
          feeAmount =
 amount.mul(_totalFee).div(feeDenominator);
          amountReceived = amount.sub(feeAmount);
          takeFee(sender, feeAmount);
          setAccFee(amount);
        } else {
          feeAmount =
 amount.mul(_totalFee).div(feeDenominator);
          amountReceived = amount.sub(feeAmount);
          takeFee(sender, feeAmount);
          setAccFee(amount);
        }

#### Recommendation

```

-----

It is recommended to modify the contract to exclude the Pinksale factory address from the

fee mechanism. This will ensure compatibility with Pinksale and facilitate the smooth

creation of pools on the platform.


-----

