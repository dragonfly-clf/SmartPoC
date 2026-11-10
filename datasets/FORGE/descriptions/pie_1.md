##### ST - Stop Transactions

###### Criticality high

 Location https://bscscan.com/address/0xd8c152d3b94084d7c8ec951e81fbbfc4b6de5b2b# code#L1351

 Description

 The contract owner has the authority to stop transactions by setting a very small amount maxWalletToken. This can functionality can be mainly used for anti-whale mechanism but the threat of also reducing the variable to extremely small percent is present.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xd8c152d3b94084d7c8ec951e81fbbfc4b6de5b2b# code#L1351|

```
require(contractBalanceRecepient + amount <= maxWalletToken,
        "Exceeds maximum wallet token amount."
     );

```

###### Recommendation

 The team should carefully manage the private keys of the owner’s account. We strongly recommend a powerful security mechanism that will prevent a single user from accessing the contract admin functions. That risk can be prevented by temporarily locking the contract or renouncing ownership.


-----

