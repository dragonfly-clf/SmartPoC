#### RES - Redundant Event Statement

**Criticality** Minor / Informative

**Location** contracts/Twelve_Days_Of_Xmas.sol#L695

**Status** Unresolved

#### Description

There are code segments that could be optimized. A segment may be optimized so that it

becomes a smaller size, consumes less memory, executes more rapidly, or performs fewer

operations.

The contract contain several `event` statement that are not used in the contract's

implemantation.
```
 event AutoLiquify(uint256 amountBNB, uint256 amountTokens);
 event Wallet_txExempt(address Wallet, bool Status);
 event Wallet_holdingExempt(address Wallet, bool Status);
 event BalanceClear(uint256 amount);
 event clearToken(address TokenAddressCleared, uint256 Amount);
 event Set_Wallets_Dev(address DevWallet);
 event config_MaxWallet(uint256 maxWallet);
 event config_MaxTransaction(uint256 maxWallet);
 event config_TradingStatus(bool Status);
 event config_LaunchMode(bool Status);

#### Recommendation

```
The team is advised to take these segments into consideration and rewrite them so the

runtime will be more performant. That way it will improve the efficiency and performance of

the source code and reduce the cost of executing it. It is recommend removing the unused

event statement from the contract..


-----

