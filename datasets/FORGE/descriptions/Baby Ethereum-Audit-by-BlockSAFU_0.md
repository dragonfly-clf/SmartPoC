MANUAL CODE REVIEW

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

2. Done use safemath after solc version 0.8.0
```
      library SafeMathInt {
         int256 private constant MIN_INT256 = int256(1) << 255;
         int256 private constant MAX_INT256 = ~(int256(1) << 255);
         /**
         * @dev Multiplies two int256 variables and fails on overflow.
         */
         function mul(int256 a, int256 b) internal pure returns
      (int256) {
           int256 c = a * b;
           // Detect overflow when multiplying MIN_INT256 with -1
           require(c != MIN_INT256 || (a & MIN_INT256) != (b &
      MIN_INT256));
           require((b == 0) || (c / b == a));
           return c;
         }

```

-----

#### 