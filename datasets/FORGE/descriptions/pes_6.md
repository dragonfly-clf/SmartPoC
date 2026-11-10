#### AOI - Arithmetic Operations Inconsistency

**Criticality** Minor / Informative

**Location** PEPESMOKING.sol#L1062,1090

**Status** Unresolved

#### Description

The contract uses both the SafeMath library and native arithmetic operations. The SafeMath

library is commonly used to mitigate vulnerabilities related to integer overflow and underflow

issues. However, it was observed that the contract also employs native arithmetic operators

(such as +, -, *, /) in certain sections of the code.

The combination of SafeMath library and native arithmetic operations can introduce

inconsistencies and undermine the intended safety measures. This discrepancy creates an

inconsistency in the contract's arithmetic operations, increasing the risk of unintended

consequences such as inconsistency in error handling, or unexpected behavior.
```
 require(balanceOf(recipient) + amount <= _maxWalletLimit,
 "Exceeds the maxWalletSize.");
 ...
 _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);

#### Recommendation

```
To address this finding and ensure consistency in arithmetic operations, it is recommended

to standardize the usage of arithmetic operations throughout the contract. The contract

should be modified to either exclusively use SafeMath library functions or entirely rely on

native arithmetic operations, depending on the specific requirements and design

considerations. This consistency will help maintain the contract's integrity and mitigate

potential vulnerabilities arising from inconsistent arithmetic operations.


-----

