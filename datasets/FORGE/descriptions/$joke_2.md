##### BT - Burn Tokens

**Criticality** high

**Location** https://bscscan.com/address/0x2df0c13487efdf4eb7f6c042273b7aca781b29a0#co
de#L1228

**Status** Resolved

###### Description

The contract owner has the authority to burn tokens from a specific address. The
owner may take advantage of it by calling the burn function. As a result the targeted
contract address will lose the corresponding tokens.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x2df0c13487efdf4eb7f6c042273b7aca781b29a0#co de#L1228|
|Status|Resolved|

```
function burn(address _from, uint256 _amount) public onlyOwner {
  _burn(_from, _amount);
}

```

###### Recommendation

The owner should carefully manage the credentials of the owner’s account. We
advised considering an extra-strong security mechanism that the actions may be
quarantined by many users instead of one. The owner could also renounce the
contract ownership for a period of time or pass the access to the zero address.

###### Resolved

The team locked the contract and has no longer access to owner functions. The
contract will be locked until 10 January 2022
https://bscscan.com/tx/0x7bd85dd8c8c7c77a52d0e49c10a7044c5a9296606b8383
d85f30a785d897da69


-----

