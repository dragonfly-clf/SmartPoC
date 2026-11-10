#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L452

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The contract owner can convert the contract into a honeypot and prevent
users from selling by increasing the selling taxes (sellTaxes.marketing,
sellTaxes.liquidity and sellTaxes.burn).

|Criticality|critical|
|---|---|
|Location|contract.sol#L452|

```
if(recipient == pair) {
       fee = amount * (sellTaxes.marketing + sellTaxes.liquidity) /
100;
       burnAmt = amount * sellTaxes.burn / 100;
    }
    else {
       fee = amount * (taxes.marketing + taxes.liquidity) / 100;
       burnAmt = amount * taxes.burn / 100;
    }
    //set fee to zero if fees in contract are handled or exempted
    if (swapping || excludedFromFees[sender] ||
excludedFromFees[recipient]) {
       fee = 0;
       burnAmt = 0;
    }
    //send fees if threshold has been reached
    //don't do this on buys, breaks swap
    if (swapEnabled && !swapping && sender != pair && fee > 0)
swapForFees();
    super._transfer(sender, recipient, amount - fee - burnAmt);

```

-----

##### Recommendation

The contract could embody a check for not allowing setting the total sellTaxes more
than a reasonable amount.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

