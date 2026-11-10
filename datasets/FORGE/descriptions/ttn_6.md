### MEM - Misleading Error Messages

**Criticality** Minor / Informative

**Location** TRITON.sol#L793,881,1126,1134,1198,1225,1256,1909,1915,1957

**Status** Unresolved

### Description

The contract is using misleading error messages. These error messages do not accurately

reflect the problem, making it difficult to identify and fix the issue. As a result, the users will

not be able to find the root cause of the error.
```
 require(totalSupply() > 0)
 require(false)
 require(stakingAmounts[duration] != bonus)
 require(!tradingEnabled)
 require(stakingEnabled != enable)
 require(swapAndLiquifyEnabled != enabled)
 require(newValue >= 200000 && newValue <= 1000000)
 require(allowCustomTokens != allow)
 require(allowAutoReinvest != allow)
 require(dividendsPaused != value)

### Recommendation

```
The team is suggested to provide a descriptive message to the errors. This message can be

used to provide additional context about the error that occurred or to explain why the

contract execution was halted. This can be useful for debugging and for providing more

information to users that interact with the contract.


-----

