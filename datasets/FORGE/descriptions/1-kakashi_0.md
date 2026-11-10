#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L848, 834, 880, 721

**Status** Resolved

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L848, 834, 880, 721|
|Status|Resolved|

```
if(from != owner() && to != owner())
       require(amount <= _maxTxAmount, "Transfer amount exceeds the
maxTxAmount.");

```

The owner can also stop transactions for multiple users by calling the
setAntibotModeWhitelist function.

```
if (!isAntibotModeEnabled) return;
    if (from == owner() || from == airdropContract) return;
    require(antibotModeWhitelist[from] && antibotModeWhitelist[to],
"Address not in antibot mode whitelist");

```

The contract owner can also convert the contract into a honeypot and prevent users
from selling by increasing the selling taxes.

```
else if(isSell){
         _taxFee = _sellTaxFee;
         _advestisementFee = _sellAdvestisementFee;
         _burnFee = _sellBurnFee;
       }

```
```
uint256 tFee = calculateTaxFee(tAmount);
    uint256 tAdvertisement = calculateAdvestisementFee(tAmount);
    uint256 tBurn = calculateBurnFee(tAmount);
    uint256 tTransferAmount =
tAmount.sub(tFee).sub(tAdvertisement).sub(tBurn);

```

-----

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
minimum amount should be more than a fixed percentage of the total supply.

The issue about antibotWhitelist will be resolved when the contract owner calls the
turnOffAntibotMode function.

The contract could embody a check for not allowing setting the total tax fees more
than 100%.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Updated 06 June 2022
The team has renounced ownership and resolved the issues.


-----

