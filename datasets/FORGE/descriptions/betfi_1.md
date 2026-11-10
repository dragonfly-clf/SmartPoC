#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1082,1092,1005

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setBuyTax, setSellTax function with a
high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1082,1092,1005|


function setBuyTax(uint256 dev, uint256 marketing, uint256 liquidity, uint256 charity) public
onlyOwner {

buyTaxes["dev"] = dev;
buyTaxes["marketing"] = marketing;
buyTaxes["liquidity"] = liquidity;
buyTaxes["charity"] = charity;
}

function setSellTax(uint256 dev, uint256 marketing, uint256 liquidity, uint256 charity) public
onlyOwner {

sellTaxes["dev"] = dev;
sellTaxes["marketing"] = marketing;
sellTaxes["liquidity"] = liquidity;
sellTaxes["charity"] = charity;
}


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

