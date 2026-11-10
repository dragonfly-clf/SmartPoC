11. Unnecessary access control

 Description

 The internal “_mint()” function is only called by the distribute() function which has the onlyOwner modifier attached to it as well. Calling it again internally will lead to extra costs spent on gas which can be avoided.

 Remediation

 Consider removing the onlyOwner modifier in the “_mint” function.

 Status

 Acknowledged


-----

###### 