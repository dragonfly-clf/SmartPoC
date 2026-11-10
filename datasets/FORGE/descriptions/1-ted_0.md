#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L757,L760,L787

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the antiBotAmount to zero
and by setting the antiBotDuration to maximum amount.

|Criticality|critical|
|---|---|
|Location|contract.sol#L757,L760,L787|


if ((sender == pair) || (recipient == pair)) {

if (!isAntiBotEnded())
{

if (!(addLPaddress[sender] || addLPaddress[recipient]))

{ require(amount <= antiBotAmount, "antiBot"); }
}
}


The contract owner can also turn the contract to honey by setting sell fees to
maximum amount with the function setFee.


if (recipient == pair) {

_liquidityFee = sellLiquidityFee;
_treasuryFee = sellTreasuryFee;
_tedRiskFreeValueFee = sellTedRiskFreeValueFe;
}


##### Recommendation

The contract could embody a check for not allowing setting the antiBotAmount,
antiBotDuration and the sell fees less than a reasonable amount. A suggested
implementation could check that the maximum amount should be more than a fixed
percentage of the total supply. In addition, the anti-bot duration should be restricted
to a reasonable amount.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

