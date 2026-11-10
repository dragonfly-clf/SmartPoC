A.1 Transfer fee bypass

 Function - transferFrom()

 Description

 If the "to" address is listed as true on the whitelist mapping and “waiveFees” is set to false, the fees payment can be bypassed by using the “approve” and “transferFrom” function.  According to the intended behavior, if "to" address is listed as “true” on the whitelist mapping and “waiveFees” is set to “false”, the fees should "always" be deducted and there must not be any other way. However, if users use transferFrom instead of transfer, they can avoid paying any fees regardless of the whitelist.

 Remediation

 Make sure to add the fee deduction functionality in the “transferFrom” function.

 Status

 Resolved

 Medium Severity Issues

 No issues were found


-----

###### 