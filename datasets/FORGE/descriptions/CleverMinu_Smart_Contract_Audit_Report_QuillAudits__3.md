A4. Incorrect require statement in transferAnyERC20Token() of HoldingContract

 Description

 transferAnyERC20Token can be used to drain all the CLEVERMINU tokens from the holding contract by a malicious admin at any point of time. The require statement is not required as it checks for _tokenAddress to be of a MAINCONTRACT which is not required.

 Remediation

 It is advised to make the changes as suggested above

 Status

 Acknowledged


-----

###### Medium Severity Issues

 