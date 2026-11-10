#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L2034

**Status** Resolved

###### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the multipleBotlistAddress function.

|Criticality|critical|
|---|---|
|Location|contract.sol#L2034|
|Status|Resolved|


function multipleBotlistAddress(address[] calldata accounts, bool excluded) public onlyOwner {

for (uint256 i = 0; i < accounts.length; i++) {

_isBlacklisted[accounts[i]] = excluded;
}
}


###### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

###### Updated 04 August 2022

The team has renounced ownership and resolved the issues.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|STC|Succeeded Transfer Check||
|⬤|BLC|Business Logic Concern|Resolved|
|⬤|CR|Code Repetition||
|⬤|L01|Public Function could be Declared External||
|⬤|L04|Conformance to Solidity Naming Conventions||
|⬤|L05|Unused State Variable||
|⬤|L07|Missing Events Arithmetic||
|⬤|L09|Dead Code Elimination||
|⬤|L12|Using Variables before Declaration||
|⬤|L14|Uninitialized Variables in Local Scope||
|⬤|L15|Local Scope Variable Shadowing||


-----

