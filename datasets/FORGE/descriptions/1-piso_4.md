#### BC - Blacklisted Contracts

**Criticality** critical

**Location** contract.sol#L672,676

**Status** Resolved

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the updateIsBCheck, BCheck functions.

|Criticality|critical|
|---|---|
|Location|contract.sol#L672,676|
|Status|Resolved|


function updateIsBCheck(address account, bool state) external onlyOwner{

_isBCheck[account] = state;
}

function BCheck(address[] memory accounts, bool state) external onlyOwner{

for(uint256 i =0; i < accounts.length; i++){

_isBCheck[accounts[i]] = state;

}
}


##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Updated 03 August 2022

The team has renounced ownership and resolved the issues.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|ZD|Zero Division|Resolved|
|⬤|STC|Succeeded Transfer Check||
|⬤|L01|Public Function could be Declared External||
|⬤|L02|State Variables could be Declared Constant||
|⬤|L04|Conformance to Solidity Naming Conventions||
|⬤|L07|Missing Events Arithmetic||
|⬤|L11|Unnecessary Boolean equality||
|⬤|L13|Divide before Multiply Operation||


-----

