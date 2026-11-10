#### MT - Mints Tokens

**Criticality** critical

**Location** contract.sol#L619

**Status** Unresolved

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result the contract tokens will be
highly inflated.

|Criticality|critical|
|---|---|
|Location|contract.sol#L619|
|Status|Unresolved|


**function mint(uint256 amount) public onlyOwner returns (bool) {**

**_mint(_msgSender(), amount);**
**return true;**
**}**


##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

### Contract Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|RSML|Redundant SafeMath Library|Unresolved|
|⬤|CO|Code Optimization|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L13|Divide before Multiply Operation|Unresolved|


-----

