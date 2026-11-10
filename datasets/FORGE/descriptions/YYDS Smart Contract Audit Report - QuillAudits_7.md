A.5: No way to withdraw stuck tokens/BNB

 Description

 In the course of transacting with contract addresses and swaps, there could be tokens mistakenly sent into the YYDS token contract and will remain stuck there with no means to claim them.

 Recommendation(s)

 Create a withdrawStuckToken() function that allows users to withdraw tokens they sent into the contract by error. Special care should be taken to not allow YYDS or USDT to be withdrawn through this function’s addition.

 Status

 Acknowledged

 A.6: Outdated libraries

 Description

 The codebase is replete with old packages from libraries that have gotten updates and newer releases. If the older versions are still in use and they contain bugs, then the entire codebase would be opened up to a larger attack surface than necessary. The ERC20 library used is an older version without the newer internal checks and custom error messages, it also uses the SafeMath library which is redundant from solidity versions >0.8.0 due to internal overflow and underflow checks. 
 The SafeERC20 library also exposes the safeApprove function which is deprecated to favor the use of safeIncreaseAllowance and safeDecreaseAllowance instead.

 Issue

 https://github.com/OpenZeppelin/openzeppelin-contracts/ issues/2219#issuecomment-622163352
 https://github.com/OpenZeppelin/openzeppelin-contracts/ blob/566a774222707e424896c0c390a84dc3c13bdcb2/contracts/token/ERC20/utils/ SafeERC20.sol#L38


-----

YYDS Audit Report


#### 