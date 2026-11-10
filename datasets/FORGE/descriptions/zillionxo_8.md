#### MC - Missing Check

**Criticality** minor / informative

**Location** contract.sol#L739,743

**Status** Unresolved

##### Description

The contract is processing variables that have not been properly sanitized and
checked that they form the proper shape. These variables may produce vulnerability
issues. The address aguments are not sanitized properly.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L739,743|
|Status|Unresolved|


function updateMarketingWallet(address newWallet) external onlyOwner {

**marketingWallet = newWallet;**
}

function updatebuybackWallet(address newWallet) external onlyOwner {

**buybackWallet = newWallet;**
}


##### Recommendation

The contract should properly check the variables according to the required
specifications. The address should not be set to zero address.


-----

