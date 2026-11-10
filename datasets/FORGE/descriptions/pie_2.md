##### BC - Blacklisted Contracts

###### Criticality high

 Location https://bscscan.com/address/0xd8c152d3b94084d7c8ec951e81fbbfc4b6de5b2b# code#L1392

 Description

 The contract owner has the authority to stop contracts from transactions. The owner may take advantage of it by calling the blacklistAddress function.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xd8c152d3b94084d7c8ec951e81fbbfc4b6de5b2b# code#L1392|

```
function blacklistAddress(address account, bool value) external onlyOwner{
    _isBlacklisted[account] = value;
  }

```

###### Recommendation

 The team should carefully manage the private keys of the owner’s account. We strongly recommend a powerful security mechanism that will prevent a single user from accessing the contract admin functions. That risk can be prevented by

 temporarily locking the contract or renouncing ownership.