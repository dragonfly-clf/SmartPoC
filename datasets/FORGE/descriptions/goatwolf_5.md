#### MC - Missing Check

**Criticality** critical

**Location** contract.sol#L592

##### Description

The contract is processing variables that have not properly sanitized and checked
that they form the proper shape. These variables may produce vulnerability issues.

The percentages can be set to values greater than 100.

|Criticality|critical|
|---|---|
|Location|contract.sol#L592|


function setPercentWallet(uint256[3] memory _pCent) public onlyOwner

{

pCent = _pCent;
}


##### Recommendation

The contract should embody a check for not allowing setting the sum of
percentages to be greater than 100%.

The contract should properly check the variables according to the required
specifications.


-----

