#### MT - Mint Tokens

**Criticality** critical

**Location** contract.sol#L1,L892

##### Description

Addresses that have the minter role have the authority to mint tokens. They may
take advantage of it by calling the mint function. As a result the contract tokens will
be highly inflated

|Criticality|critical|
|---|---|
|Location|contract.sol#L1,L892|

```
function mint(address _to, uint256 _value) public onlyMinter returns (bool
_success) {
 return _mint(_to, _value);
}

```

##### Recommendation

If this functionality is required by the business logic, then there should be some
limits to the maximum amount of tokens that can be minted from every address.

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
|⬤|L04|Conformance to Solidity Naming Conventions|
|⬤|L09|Dead Code Elimination|


-----

