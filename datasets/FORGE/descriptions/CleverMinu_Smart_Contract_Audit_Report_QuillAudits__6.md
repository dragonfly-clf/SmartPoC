A7. Incorrect require statement in setIMOendTime()

 Description

 On line: 354 the require statement is potentially incorrect

 There is mismatch between error message and require statement. 

   require(time > getBlocktimestamp(),"End time cannot be old time");   Should be used instead

 Remediation

 It is advised to use safeIncreaseAllowance and safeDecreaseAllowance such as that from Open Zeppelin instead.

 Refer: https://swcregistry.io/docs/SWC-114

 Status

 Resolved


-----

###### Low Severity Issues

 