Approve Front Running Attack (2 Items)

```
**Function** **Severity** **Remedation**
```
The approve() method Only use the approve function
overrides current of the ERC/BEP standard to
allowance regardless of change the allowed amount to 0
whether the spender or from 0 (wait till
already used it or not, so Severity transaction is mined and
there is no way to : High approved).
increase or decrease Token owner just needs to make
allowance by a certain sure that the first
value atomically unless transaction actually changed
the token owner is a smart allowance from N to 0, i.e.,
contract, not an account. that the spender didn't manage
This can be abused by a to transfer some of N allowed
token receiver when they tokens before the first
try to withdraw certain transaction was mined. Such
tokens from the sender's checking is possible using
account. advanced blockchain explorers
Meanwhile, if the sender such as
decides to change the [Etherscan.io](https://ethersc
amount and sends another an.io/)

```
|Function|Severity|Remedation|
|---|---|---|


-----

|approve transaction, the receiver can notice this transaction before it's mined and can extract tokens from both the transactions, therefore, ending up with tokens from both the transactions. This is a front-running attack affecting the ERC20 Approve function. The function approve can be front-run by abusing the _approve function.|Col2|Another way to mitigate the threat is to approve token transfers only to smart contracts with verified source code that does not contain logic for performing attacks like described above, and to accounts owned by the people you may trust.|
|---|---|---|


-----

```
Contract Flow Graph

```

-----

```
Inheritance Graph

```

-----

```
Contract Descriptions

```
|Contract|Type|Bases|Col4|Col5|
|---|---|---|---|---|
||Function Name|Visibility|Mutability|Modifiers|
||||||
|Context|Implementation||||
||_msgSender|Internal|||
||_msgData|Internal|||
||||||
|Ownable|Implementation|Context|||
|||Public||NO|
||owner|Public||NO|
||_checkOwner|Internal|||
||renounceOwnership|Public||onlyOwner|
||transferOwnership|Public||onlyOwner|
||_transferOwnership|Internal|||
||||||
|IERC20|Interface||||
||totalSupply|External||NO|
||balanceOf|External||NO|
||transfer|External||NO|
||allowance|External||NO|
||approve|External||NO|
||transferFrom|External||NO|
||||||
|IERC20Metadata|Interface|IERC20|||
||name|External||NO|
||symbol|External||NO|
||decimals|External||NO|


-----

_transfer Internal

|ERC20|Implementation|Context, IERC20, IERC20Metadata|Col4|Col5|
|---|---|---|---|---|
|||Public||NO|
||name|Public||NO|
||symbol|Public||NO|
||decimals|Public||NO|
||totalSupply|Public||NO|
||balanceOf|Public||NO|
||transfer|Public||NO|
||allowance|Public||NO|
||approve|Public||NO|
||transferFrom|Public||NO|
||increaseAllowance|Public||NO|
||decreaseAllowance|Public||NO|
||_transfer|Internal|||
||_mint|Internal|||
||_burn|Internal|||
||_approve|Internal|||
||_spendAllowance|Internal|||
||_beforeTokenTransfer|Internal|||
||_afterTokenTransfer|Internal|||
||||||
|SCCS|Implementation|ERC20, Ownable|||
|||Public||ERC20|
||setPairAddress|External||onlyOwner|
||publicBurn|External||NO|
||_transfer|Internal|||


Function
can modify

state


Function
is payable


-----

```
Source:
File Name SHA-1 Hash
c:\Solidity\successkid.sol 6d0937e60e2f453bd40fe2f8e20f124c4bf3eae1

```

-----

```
Audit Scope
Audit Method.
Our smart contract audit is an extensive methodical examination and
analysis of the smart contract’s code that is used to interact with
the blockchain. Goal: discover errors, issues and security
vulnaribilities in the code. Findings getting reported and
improvements getting suggested.
Automatic and Manual Review
We are using automated tools to scan functions and weeknesses of the
contract. Transfers, integer over-undeflow checks such as all CWE
events.
Tools we use: 
Visual Studio Code
CWE
SWC
Solidity Scan
SVD
In manual code review our auditor looking at source code and
performing line by line examination. This method helps to clarify
developer’s coding decisions and business logic.
Skeleton Ecosystem
https://skeletonecosystem.com
https://github.com/SkeletonEcosystem/Audits

