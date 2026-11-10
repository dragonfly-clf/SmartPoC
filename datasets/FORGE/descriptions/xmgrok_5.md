#### MEM - Misleading Error Messages

**Criticality** Minor / Informative

**Location** XMasGrok.sol#L386,392

**Status** Unresolved

#### Description

The contract is using misleading error messages. These error messages do not accurately

reflect the problem, making it difficult to identify and fix the issue. As a result, the users will

not be able to find the root cause of the error.
```
 require(_msgSender() == _developmentAddress || _msgSender() ==
 _marketingAddress || _msgSender() == owner())

#### Recommendation

```
The team is suggested to provide a descriptive message to the errors. This message can be

used to provide additional context about the error that occurred or to explain why the

contract execution was halted. This can be useful for debugging and for providing more

information to users that interact with the contract.


-----

