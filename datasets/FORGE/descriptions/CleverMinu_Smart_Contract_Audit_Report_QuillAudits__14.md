A15. Unnecessary usage of function (Informational)

 Description

 A separate safeDiv256() function is not needed as safeDiv() function works for uint256 values as well

 Remediation

 It is advised to remove the safeDiv() function from the contract

 Status

 Resolved

 