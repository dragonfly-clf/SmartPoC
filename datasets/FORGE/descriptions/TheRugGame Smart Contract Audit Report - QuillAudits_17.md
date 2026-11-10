2. Ownership transfer

 Description

 The transferOwnership() function in contract allows the current admin to transfer his privileges to another address. However, inside transferOwnership() , the newOwner is directly stored into the storage owner, after validating the newOwner is a non- zero address, and immediately overwrites the current owner. This can lead to cases where the admin has transferred ownership to an incorrect address and wants to revoke the transfer of ownership or in the cases where the current admin comes to know that the new admin has lost access to his account.

 Remediation

 It is advised to make ownership transfer a two-step process. Refer- https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/ Ownable2Step.sol and https://github.com/razzorsec/RazzorSec-Contracts/blob/main/AccessControl/SafeOwn.sol

 Status

 Acknowledged

 