A.3: Use of two-step ownable

 File(s)

 YYDS.sol

 Description

 If ownership transfer is not done appropriately, the current contract owner can renounce/ transfer ownership, lose owner privileges, and lose the ability to burn tokens. When ownership is renounced, all of the contract’s methods will be rendered unusable.

 Remediation

 Functions such as renounceOwnership and transferOwnership can be overridden or set up for 2-step verification to prevent mistaken privilege transfer or renouncing.

 References

 https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/ Ownable2Step.sol and https://github.com/razzorsec/RazzorSec-Contracts/blob/main/ AccessControl/SafeOwn.sol

 Status

 Acknowledged

 