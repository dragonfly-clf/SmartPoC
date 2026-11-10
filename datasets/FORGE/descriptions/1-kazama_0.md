#### MT - Mints Tokens

**Criticality** critical

**Location** contract.sol#L1609

**Status** Unresolved

##### Description

The contract owner has the authority to mint tokens. The owner may take
advantage of it by calling the mint function. As a result the contract tokens will be
highly inflated.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1609|
|Status|Unresolved|

```
/// @notice Creates `_amount` token to `_to`. Must only be called by an contract
with the SenshiMaster role (i.e SenshiMaster & Bridge contract).
function mint(address _to, uint256 _amount) public OnlySenshiMaster {
  _mint(_to, _amount);
  _moveDelegates(address(0), _delegates[_to], _amount);
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

### Contract Diagnostics

|Severity|Code|Description|Status|
|---|---|---|---|
|⬤|L01|Public Function could be Declared External|Unresolved|
|⬤|L02|State Variables could be Declared Constant|Unresolved|
|⬤|L04|Conformance to Solidity Naming Conventions|Unresolved|
|⬤|L07|Missing Events Arithmetic|Unresolved|
|⬤|L09|Dead Code Elimination|Unresolved|
|⬤|L11|Unnecessary Boolean equality|Unresolved|


-----

