#### MANUAL CODE REVIEW

 Minor-risk

 2 minor-risk code issue found

 Could be fixed, and will not bring problems.

1. The return value of an external transfer/transferFrom return value is checked.

Recommendation: use SafeERC20, or ensure that the transfer/transferFrom return
value is checked

function transferFrom(

address sender,
address recipient,
uint256 amount
) external returns (bool);

2. Marketing and dev wallet same address

Recommendation: change marketing and dev wallet (must be different), because
investor can’t tracking if the wallet same)
```
      mktFeeReceiver =
      address(0x53cA2a894406848fbB34444859013F068F52FBe1);
      teamFeeReceiver =
      address(0x53cA2a894406848fbB34444859013F068F52FBe1);

#### Medium-risk

 0 medium-risk code issues found

 Should be fixed, could bring problems.

```

-----

