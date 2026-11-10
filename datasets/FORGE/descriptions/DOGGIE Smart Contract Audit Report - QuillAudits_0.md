#### High severity issues

###### 1. Bypass trading fee and burning fee

 Description The burnAmount and feeAmount are calculated by the following operations:
 burnAmount = amount.mul(tradeBurnRatio).div(10000); feeAmount = amount.mul(tradeFeeRatio).div(10000);
 Unfortunately, Solidity integer division truncates, therefore, if the amount.mul(tradeBurnRatio) is smaller than 10000. The burnAmount is always Zero, similar to the feeAmount.
 Moreover, the _tradeBurnRatio and _tradeFeeRatio are set by the following statements:
 require(_tradeBurnRatio >= 0 && _tradeBurnRatio <= 5000, "TRADE_BURN_RATIO_INVALID"); require(_tradeFeeRatio >= 0 && _tradeFeeRatio <= 5000, "TRADE_FEE_RATIO_INVALID");
 The values between this range (0->5000) does not help to prevent the issue, if the amount.mul(tradeBurnRatio) < 10000, the operation will return 0.
 Remediation Consider implementing if statements where appropriate to validate all user-controlled input, including constructor, to avoid the potential for erroneous values to result in unexpected behaviors or wasted gas. Please ensure that the amount.mul(tradeBurnRatio) and amount.mul(tradeFeeRatio) are always greater than 10000.

 Status: Open

 05


-----

#### Medium severity issues

###### No issues were found.

