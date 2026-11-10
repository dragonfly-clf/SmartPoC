#### OTUT - Owner Transfer User's Tokens

**Criticality** critical

**Location** contract.sol#L1796

##### Description

The contract owner has the authority to transfer any balance to the owner’s
contract. The owner may take advantage of it by:

 - Set the account to an addresses that holds tokens, (setAccount())

 - Set the controller role to the owner’s address, (setController())

 - Execute the withDraw() method

|Criticality|critical|
|---|---|
|Location|contract.sol#L1796|

```
function withDraw(address to, uint256 amount)
  external
  override
  onlyRole(CONTROL_ROLE)
{
  _transfer(_account, to, amount);
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

We state that the owner privileges are necessary and required for proper
**protocol operations. Thus, we emphasise the contract owner to be extra careful**
with the credentials.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|
|---|---|---|
|⬤|L01|Public Function could be Declared External|
|⬤|L09|Dead Code Elimination|
|⬤|L12|Using Variables before Declaration|


-----

