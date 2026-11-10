#### BT - Burn Tokens

**Criticality** critical

**Location** contract.sol#L1511

##### Description

The contract owner has the authority to burn tokens from a specific address. The
owner may take advantage of it by calling the burn function. As a result the targeted
contract address will lose the corresponding tokens.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1511|


function burn(address account, uint256 amount)

external
onlyRole(BURNER_ROLE)
{

_burn(account, amount);
}


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
|⬤|FSA|Fixed Swap Address|
|⬤|L01|Public Function could be Declared External|
|⬤|L02|State Variables could be Declared Constant|
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|
|⬤|L14|Uninitialized Variables in Local Scope|


-----

