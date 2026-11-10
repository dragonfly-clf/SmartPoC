## QSP-6 Privileged Roles and Ownership

#### Severity: Informational

 Status: Acknowledged

###### File(s) affected: RariFundController.sol, RariFundManager.sol

 Description: Smart contracts will often have owner variables to designate the person with special privileges to make modifications to the smart contract. There are multiple privileged roles in the system, including: contract owners, rebalancers and Rari fund managers/controllers.

#### 1. The owner of the RariFundController contract is allowed to:

          - disable and enable the Rari fund at any point in time.

          - set the daily loss rate limit to any value at any time.

          - forward all funds in the contract to any EOA.

          - change the `RariFundToken` and `RariFundProxy` address at any time.

#### 2. The Rari Fund rebalancer is allowed to:

          - withdraw all funds from any and all pools at any time.

          - approve any amount to 0x exchange.

          - create sell orders on the 0x exchange.

#### 3. The owner of the RariFundManager contract is allowed to withdraw all funds (of any token type, including ETH) out of this smart contract to their own account.


###### Recommendation:


###### This centralization of power needs to be made clear to the users, especially depending on the level of privilege the contract allows to the owner.


###### Update: New documentation has been added to CONCEPT.md.

