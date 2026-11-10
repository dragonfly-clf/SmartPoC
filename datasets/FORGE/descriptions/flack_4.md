#### MCM - Misleading Comment Messages

**Criticality** Minor / Informative

**Location** Flack.sol#L177

**Status** Unresolved

#### Description

The contract is using misleading comment messages. These comment messages do not

accurately reflect the actual implementation, making it difficult to understand the source

code. As a result, the users will not comprehend the source code's actual implementation.
```
 // Anti Whale Mechanism with 1% of Max Bag and Transaction
 uint256 public maxTransaction = _totalSupply.mul(5).div(100);
 uint256 public maxWallet = _totalSupply.mul(3).div(100);

#### Recommendation

```
The team is advised to carefully review the comment in order to reflect the actual

implementation. To improve code readability, the team should use more specific and

descriptive comment messages.


-----

