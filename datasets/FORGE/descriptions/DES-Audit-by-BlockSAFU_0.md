MANUAL CODE REVIEW
 Minor-risk 3 minor-risk code issues found Could be fixed, and will not bring problems.

1. The return value of an external transfer/transferFrom return value is checked.

Recommendation: use SafeERC20, or ensure that the transfer/transferFrom return
value is checked
function transferFrom(

address sender,
address recipient,
uint256 amount   )
external returns (bool);

2. Lack of Zero Check, the funding address not checkin if the address is zero,

consequence the tokenomic can’t work like normally.

function setFundAddress(address addr) external onlyFunder

{ fundAddress = addr; _feeWhiteList[addr] = true;
}

3. Divide before multiply, solidity can’t have decimal, if the divition amount is greater

than amount, the result is zero, this schema can have unprecision amount
_takeTransfer(sender,recipient,(tAmount / 100) * 1,currentRate)


-----

### 