1. Centralization Risk

 Description

 The contract owner can adjust the tax to as high as 100% on transactions, limit the tradeable limit of each user’s balance. The owner account should be taken care to not be mismanaged else the privileges associated with the account can slip into the hands of the hacker. Also, if renouncing ownership is not done appropriately, the current contract owner can renounce ownership, and lose access to owner privileges. Functions like setting tax, and wallet addresses will be uncallable and any updates needed to be made will be inaccessible.

 Remediation

 Carefully manage the owner account by using a multi-signature wallet or implementing community governance to ensure that updates to the project happen by some form of consensus. A timelock can be implemented between changes as well. The renounceOwnership() and transferOwnership() can be set up for 2-step verification to prevent mistaken privilege transfer or renouncing.

 References

  - Link 1  - Link 2

 Status

 Acknowledged


-----

###### 