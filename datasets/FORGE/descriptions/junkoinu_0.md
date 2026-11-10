#### BT - Burn Tokens

**Criticality** high

**Location** https://bscscan.com/address/0x8983a6f5b70315f9373d39e14de5afeabf835588#co
de#L841

##### Description

The contract owner has the authority to burn tokens from the contract’s total supply.
The owner may take advantage of it by calling the burn function.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x8983a6f5b70315f9373d39e14de5afeabf835588#co de#L841|

```
function _burn(address account, uint256 amount) public virtual onlyOwner{
  require(account != address(0), "ERC20: burn from the zero address");
  _tTotal -= amount;
}

```

##### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.


-----

