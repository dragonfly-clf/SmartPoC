#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L767, 797

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the fees (_marketingFee,
_liquidityFee, _taxFee, _BurnFee) to a high percentage value.

|Criticality|medium|
|---|---|
|Location|contract.sol#L767, 797|

```
if(!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]){
  transferAmount = collectFee(sender,amount,rate);
}

```

-----

```
function collectFee(address account, uint256 amount, uint256 rate) private
returns (uint256) {
    uint256 transferAmount = amount;
    uint256 marketingFee = amount.mul(_marketingFee).div(10000);
    uint256 liquidityFee = amount.mul(_liquidityFee).div(10000);
    uint256 taxFee = amount.mul(_taxFee).div(10000);
    uint256 BurnFee = amount.mul(_BurnFee).div(10000);
    //@dev for holders distribution
    if (taxFee > 0) {
       transferAmount = transferAmount.sub(taxFee);
       _reflectionTotal = _reflectionTotal.sub(taxFee.mul(rate));
       _taxFeeTotal = _taxFeeTotal.add(taxFee);
       emit RewardsDistributed(taxFee);
    }
    //@dev Marketing fee
    if(marketingFee > 0){
       transferAmount = transferAmount.sub(marketingFee);
       _reflectionBalance[marketingAddress] =
_reflectionBalance[marketingAddress].add(marketingFee.mul(rate));
       _marketingFeeTotal = _marketingFeeTotal.add(marketingFee);
       emit Transfer(account,marketingAddress,marketingFee);
    }
    //@dev Burn fee
    if(BurnFee > 0){
       transferAmount = transferAmount.sub(BurnFee);
       _reflectionBalance[BurnAddress] =
_reflectionBalance[BurnAddress].add(BurnFee.mul(rate));
       _BurnFeeTotal = _BurnFeeTotal.add(BurnFee);
       emit Transfer(account,BurnAddress,BurnFee);
    }
    //@dev Liquidity fee
    if(liquidityFee > 0){
       transferAmount = transferAmount.sub(liquidityFee);
       _reflectionBalance[liquidityAddress] =
_reflectionBalance[liquidityAddress].add(liquidityFee.mul(rate));
       _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);
       emit Transfer(account,liquidityAddress,liquidityFee);
    }

```

-----

##### Recommendation

The contract could embody a check for not allowing setting the _marketingFee,
_liquidityFee, _taxFee and _BurnFee more than a reasonable amount.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

