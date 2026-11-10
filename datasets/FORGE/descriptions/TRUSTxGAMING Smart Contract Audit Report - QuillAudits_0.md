High Severity Issues

 A.1 Contract Owner Can Increase Its Balance When Burning Tokens in Any Account and Causing an     Inconsistency with the Total Supply

 Description

 The burn function can only be called by the contract owner. This implies that the owner can burn tokens from any user account. The issue of increasing the owner’s balances arises at the level of the _burn internal function. When the contract owner passes an user account address to the public burn function, it deducts the amount from the balance of the user, increasing the balance of the contract owner but also reduces the total supply value. This will cause an inconsistency with the value of tokens in circulation. There will be more tokens in the contract owner’s balance but less tokens noted by the total supply variable.

 Remediation

 Since the tokens burned are to be redistributed to users, it is recommended to also add the expected amount to be burned with the total supply to maintain a consistency with the value of the total supply.

 Status

 Acknowledged


-----

###### 