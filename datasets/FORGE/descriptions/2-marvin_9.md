#### MCM - Misleading Comment Messages

**Criticality** Minor / Informative

**Location** MarvinInu.sol#L962

**Status** Unresolved

#### Description

The contract is using misleading comment messages. These comment messages do not

accurately reflect the actual implementation, making it difficult to understand the source

code.

Specifically, the comment associated with the `maxWallet` variable suggests that it

represents `1.5%` of the totalSupply. However, the `maxWallet` variable is actually

equivalent to `2%` of the totalSupply, not the `1.5%` as indicated by the comment. As a

result, the users will not comprehend the source code's actual implementation.
```
 maxWallet = totalSupply * 20 / 1000; // 1.5% maxWallet

#### Recommendation

```
The team is advised to carefully review the comment in order to reflect the actual

implementation. To improve code readability, the team should use more specific and

descriptive comment messages.


-----

