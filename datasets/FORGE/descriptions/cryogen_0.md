##### BC - Blacklisted Contracts

###### Criticality high

 Location https://bscscan.com/address/0xb6b0f5dd8b12cf7f4a3ebe7e3e6e97b56b02d0ad#c ode#L2731

 Description

 The contract owner has the authority to stop contracts from transactions. The owner may take advantage of it by calling the blacklistAddress function.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xb6b0f5dd8b12cf7f4a3ebe7e3e6e97b56b02d0ad#c ode#L2731|

```
function blacklistAddress(address account, bool value) external onlyOwner {
  _isBlacklisted[account] = value;
}

```

###### Recommendation

 The team should carefully manage the private keys of the owner’s account. We strongly recommend a powerful security mechanism that will prevent a single user from accessing the contract admin functions. That risk can be prevented by temporarily locking the contract or renouncing ownership.


-----

