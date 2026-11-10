Minor-risk

 1 minor-risk code issue found

 Could be fixed, and will not bring problems.

1. The return value of an external transfer/transferFrom return value is checked.

Recommendation: use SafeERC20, or ensure that the transfer/transferFrom return
value is checked

function transferFrom(

address sender,
address recipient,
uint256 amount
) external returns (bool);

#### 