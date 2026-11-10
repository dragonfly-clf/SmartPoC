15. Redundant parameters in calculateBNBReward() function

 Description It was discovered that the _tTotal and ofAddress variables are not used in calculateBNBReward() function. Unused code is allowed in Solidity, and they do not pose a direct security issue. It is best practice,though, to avoid them as they can:

   cause an increase in computations (and unnecessary gas    consumption)   indicate bugs or malformed data structures, and they are generally a    sign of poor code quality   cause code noise and decrease the readability of the code

 Remediation We recommend removing all unused above-mentioned parameters used in the calculateBNBReward() function.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit a3cbe787da2da67eb2895c79e75f8d25a2d7436a

 0515


-----

|Line|Code|
|---|---|
|1384-1385 _isExcludedFromMaxTx[from] == false && // default will be false _isExcludedFromMaxTx[to] == false // default will be false||


###### 