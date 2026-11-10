#### BT - Burn Tokens

**Criticality** critical

**Location** contract.sol#L804

##### Description

The contract owner has the authority to burn tokens from a specific address. The
owner may take advantage of it by calling the managerBurn function. As a result the
targeted contract address will lose the corresponding tokens.

|Criticality|critical|
|---|---|
|Location|contract.sol#L804|

```
function managerBurn(address account, uint256 amount) onlyOwner public {
  require(totalSupply().sub(amount) >= 0, "exceeds.");
  _burn(account, amount);
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|CO|Code Optimization|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L05|Unused State Variable|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L12|Using Variables before Declaration|
|⬤|L15|Local Scope Variable Shadowing|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

