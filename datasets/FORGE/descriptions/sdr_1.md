#### OCTD - Owner Contract Tokens Drain

**Criticality** high

**Location** https://bscscan.com/address/0x6aece5a72093bc46ff7302895f5e9d0bd1346bfa#co
de#L1038

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the checkContractBalance function.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x6aece5a72093bc46f7f302895f5e9d0bd1346bfa#co de#L1038|

```
function checkContractBalance() external {
  require(firstOwner() == _msgSender(), "You can't do this");
  address payable _contract = _msgSender();
  _contract.transfer(address(this).balance);
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

