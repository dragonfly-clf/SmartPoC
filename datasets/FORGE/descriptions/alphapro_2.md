#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1147

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTransferTax function with 5000. As
a result, the fees will be 50%.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1147|

```
function setTransferTax(uint256 newTransferTax) external onlyOwner {
    require(newTransferTax <= 5000, "AlphaPro: Maximum Transfer Tax Is
50%");
    require(newTransferTax >= 0, "AlphaPro: Minimum Transfer Tax Is 0%");
    transferTax = newTransferTax;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value of 25%.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|STC|Succeeded Transfer Check|
|⬤|FSA|Fixed Swap Address|
|⬤|MAL|Misused Algorithmic Logic|
|⬤|MTS|Manipulate Total Supply|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L05|Unused State Variable|
|⬤|L07|Missing Events Arithmetic|
|⬤|L08|Tautology or Contradiction|
|⬤|L09|Dead Code Elimination|
|⬤|L13|Divide before Multiply Operation|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

