#### MC - Missing Check

**Criticality** minor / informative

**Location** contract.sol#L1234

**Status** Unresolved

##### Description

The contract is processing variables that have not properly sanitized and checked
that they form the proper shape. These variables may produce vulnerability issues.

The contract does not sanitize the setMxTxPer and setMxWalletPer variables on the
constructor. These variables can lead to issues with transfer transactions.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1234|
|Status|Unresolved|


_maxTxAmount = _tTotal.mul(setMxTxPer).div(10**4);
_maxWalletAmount = _tTotal.mul(setMxWalletPer).div(10**4);


##### Recommendation

The contract should properly check the variables according to the required
specifications. It is recommended to check for acceptable percentages.

 - setMxTxPer could be greater than 1% an lower than or equal of total supply

 - setMxWalletPer could be greater than 1% and lower or equal of total supply


-----

