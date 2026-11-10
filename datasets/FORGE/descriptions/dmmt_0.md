#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1374,L11730,L1424

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _minBuyTxAmount to
minimum amount. By setting the _minBuyTxAmount to 1 it makes the buying
transaction almost impossible.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1374,L11730,L1424|


require(

amount >= _minBuyTxAmount,
"Buy transfer amount must exceeds the minBuyTxAmount."
);


The owner can convert the contract into a honeypot and prevent users from selling
by setting coolDownTimestamp to the maximum amount.


require(

coolDownTimestamp < block.timestamp,
"Wait till one hour Cool Down Pd"
);


The owner can also stop transactions by setting _liquidityFee and _marketingFee to
zero. The sum for these values is combineFees which is the denominator of
tokenForLiquidity. When combineFees is zero the transaction will be reverted.


combineFees = _liquidityFee.add(_marketingFee);
uint256 tokensForLiquidity = contractTokenBalance

.mul(_liquidityFee)
.div(combineFees);


##### Recommendation

The contract could embody a check for not allowing setting the _maxSellTxAmount
and _minBuyTxAmount less than a reasonable amount. A suggested


-----

implementation could check that the maximum amount should be more than a fixed
percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

