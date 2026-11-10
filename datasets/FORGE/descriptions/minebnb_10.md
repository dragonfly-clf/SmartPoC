#### MEM - Misleading Error Messages

**Criticality** Minor / Informative

**Location** MineBNB.sol#L195,201,623,686

**Status** Unresolved

#### Description

The contract is using misleading error messages. These error messages do not accurately

reflect the problem, making it difficult to identify and fix the issue. As a result, the users will

not be able to find the root cause of the error.
```
 require(!initialized)
 require(msg.sender == _token)
 require(holder != address(this) && holder != pair)
 require(gas < 750000)

#### Recommendation

```
The team is suggested to provide a descriptive message to the errors. This message can be

used to provide additional context about the error that occurred or to explain why the

contract execution was halted. This can be useful for debugging and for providing more

information to users that interact with the contract.


-----

