1. Ownership and Privilege transfer

 If renouncing ownership is not done appropriately, the current contract owner can renounce ownership, lose owner privileges, and lose access to the tokens sent to the contract forever. When ownership is renounced, functions like withdraw will be uncallable and any tokens gotten from transactions, or even mistaken deposits into the contract will be inaccessible.

 Recommendation

 Functions such as renounceOwnership and transferOwnership can be overridden or set up for 2-step verification to prevent mistaken privilege transfer or renouncing.

 References - Link 1 | Link 2

 Status

 Resolved

 Auditor’s Remark - The client has implemented SafeOwn’s 2-step ownership transfers to mitigate the risk described above.

 