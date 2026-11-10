#### SPC - Solidity Precision Concern

**Criticality** minor / informative

**Location** contract.sol#L690,694

**Status** Unresolved

##### Description

In Solidity, all integer division rounds down to the nearest integer. The contract
distributes the funds proportional to the recipients. These calculations may produce
unexpected leftover funds for the contract.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L690,694|
|Status|Unresolved|


uint256 marketingAmt = unitBalance * 2 * temp.marketing;
if (marketingAmt > 0) {

payable(marketingWallet).sendValue(marketingAmt);
}
uint256 buybackAmt = unitBalance * 2 * temp.buyback;
if (buybackAmt > 0) {

payable(buybackWallet).sendValue(buybackAmt);
}


##### Recommendation

In Solidity, all integer division rounds down to the nearest integer. The contract
distributes the funds proportional to the recipients. These calculations may produce
unexpected leftover funds for the contract.


-----

