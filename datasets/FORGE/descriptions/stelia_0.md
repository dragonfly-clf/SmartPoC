#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L810, 851, 694

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by enabling/disabling the
isAntibotModeEnabled boolean.

|Criticality|critical|
|---|---|
|Location|contract.sol#L810, 851, 694|

```
if (!isAntibotModeEnabled) return;
if (from == owner() || from == airdropContract) return;
require(antibotModeWhitelist[from] && antibotModeWhitelist[to], "Address not
in antibot mode whitelist");

```

The contract owner can also convert the contract into a honeypot and prevent users
from selling by increasing the selling taxes.

```
}else if(isSell){
_taxFee = _sellTaxFee;
_advestisementFee = _sellAdvestisementFee;
}

```
```
uint256 tFee = calculateTaxFee(tAmount);
uint256 tAdvertisement = calculateAdvestisementFee(tAmount);
uint256 tBurn = calculateBurnFee(tAmount);
uint256 tTransferAmount = tAmount.sub(tFee).sub(tAdvertisement).sub(tBurn);

```

-----

##### Recommendation

The contract could embody a check for not allowing setting the total fees more
than a reasonable amount.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

