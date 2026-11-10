#### ST - Stops Transactions

**Criticality** critical

**Location** contract.sol#L1182

**Status** Unresolved

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the totalSellFee to 100%. As
a result, the contract may operate as a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1182|
|Status|Unresolved|


if(takeFee) {

uint16 totalFee;

if(automatedMarketMakerPairs[from]){

totalFee = totalBuyFee;
}else if(automatedMarketMakerPairs[to]){

**totalFee = totalSellFee;**
}

uint256 fees = amount.mul(totalFee).div(100);
**amount = amount.sub(fees);**
**super._transfer(from, address(this), fees);**

}

super._transfer(from, to, amount);


##### Recommendation

The contract could embody a check for not allowing setting the totalSellFee over the
allowed limit. More information on ELFM - Exceeds Fees Limit.


-----

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

