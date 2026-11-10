#### BT - Burn Tokens

**Criticality** critical

**Location** https://bscscan.com/address/0x6aece5a72093bc46ff7302895f5e9d0bd1346bfa
#code#L1256

##### Description

The contract owner has the authority to burn tokens from a specific address. The
owner may take advantage of it by calling the burn function. As a result the targeted
contract address will lose the corresponding tokens.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0x6aece5a72093bc46f7f302895f5e9d0bd1346bfa #code#L1256|

```
 function burn(address account, uint256 amount) public onlyOwner
returns(bool) {
  _burn(account, amount);
  return true;
 }

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account to
protect against potential hacks. Temporarily locking the contract or renouncing the
contract ownership will eliminate this threat.


-----

