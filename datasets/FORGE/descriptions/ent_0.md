#### MT - Mint Tokens

**Criticality** critical

**Location** contract.sol#L499

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result the contract tokens will be
highly inflated

|Criticality|critical|
|---|---|
|Location|contract.sol#L499|

```
function mint(uint256 amount) public onlyOwner returns (bool) {
 _mint(_msgSender(), amount);
 return true;
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
|⬤|L01|Public Function could be Declared External|
|⬤|L09|Dead Code Elimination|


-----

