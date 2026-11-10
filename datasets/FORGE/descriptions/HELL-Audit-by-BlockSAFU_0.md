#### MANUAL CODE REVIEW

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

#### Medium-risk

 0 medium-risk code issues found

 Should be fixed, could bring problems.

 High-Risk

 0 high-risk code issues found

 Must be fixed, and will bring problem.

 Critical-Risk 0 critical-risk code issues found

 Must be fixed, and will bring problem.