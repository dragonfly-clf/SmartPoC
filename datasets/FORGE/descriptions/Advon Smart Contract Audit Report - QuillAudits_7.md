8. Unused code

 Description

 The contract declares IPancakeFactory, IPancakeRouter, and IPancakePair but they are not implemented in any form throughout the scope of the codebase. TradeableLimit, ProcessingFee, and NetworkingFee are declared but not implemented as well. The dev’s comment implied that tradeLimit allows only a certain percentage of the user’s tokens to be tradeable at a certain time. The current version of the codebase does not put this functionality to use.

 Remediation

 Consider cleaning up the contract by removing the unused interfaces, implementing said functionality, and deleting dead code to help reduce the contract size and aid deployment.

 Status

 Acknowledged

 Informational Issues

 