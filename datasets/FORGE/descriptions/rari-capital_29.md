## QSP-30 Fallback function can receive funds from any address (2)

#### Severity: Informational

 Status: Acknowledged

###### File(s) affected: RariFundController.sol in rari-ethereum-pool-fund RariFundProxy.sol in rari-ethereum-pool-fund,

 Description: The fallback function is meant to only be “called by 0x exchange to refund unspent protocol fee.” However, there are no restrictions/checks in place to guarantee this. This means that anyone could send funds to this contract by mistake.

 Recommendation: Add a requirement inside the fallback function to check if the msg.sender address belongs to 0x, as is already done in the same function and contract from the rari- stable-pool-contracts repo. This way the function will revert if any other address sends funds to it.


###### Update from dev team:


###### This address validation function will be added in the next version of the contracts.


-----

