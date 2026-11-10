#### MEM - Misleading Error Messages

**Criticality** Minor / Informative

**Location** ZangAi.sol#L558

**Status** Unresolved

#### Description

The contract is using misleading error messages. These error messages do not accurately

reflect the problem, making it difficult to identify and fix the issue.

The use of the term "native tokens" in the error message is misleading. The intent behind

the message is to indicate that the owner of the contract should not be able to claim tokens

associated with the contract itself, rather than referring to tokens native to the blockchain.
```
 require(token != address(this), "Owner cannot claim native
 tokens");

#### Recommendation

```
The team is suggested to modify the error message and remove the term `native` . This

modification will help users understand that the prohibition pertains to tokens specifically

linked to the contract, rather than implying a restriction on native tokens.


-----

