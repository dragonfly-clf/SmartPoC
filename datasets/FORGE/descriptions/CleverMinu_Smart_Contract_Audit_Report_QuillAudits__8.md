A9. Lack of sanity checks

 Description

 No sanity value checks for IMO_BURNRATIO in setIMOBurnRatio function. It is possible to set setIMOBurnRatio greater than 100, which could result in more tokens being sent for burning than intended during the execution of IMOsale function.

 Remediation

 Consider using the latest solidity version.

 Status

 Resolved


-----

###### 