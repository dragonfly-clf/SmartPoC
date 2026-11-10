#### TSED - Total Supply External Dependency

**Criticality** critical

**Location** contract.sol#L1164

**Status** Unresolved

##### Description

The total supply of the Bworker token depends on the external contract
```
nftContract.totalProfitAt(epoch);. If the nftContract manipulated or have

```
an issue, then it may affect the total supply of Bworker token unpredictable.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1164|
|Status|Unresolved|

```
(uint256 lqTokenAmount, uint256 lqBNBAmount) = tokenPrice();
uint256 mintAmount = 0;
if (lqBNBAmount.mul(lqTokenAmount) > 0) {
  for (
    uint256 epoch = lastMintEpoch.add(1);
    epoch < _currentEpoch;
    epoch++
  ) {
    uint256 BNBAmount = nftContract.totalProfitAt(epoch);
    uint256 tokenAmount;
    tokenAmount = BNBAmount.mul(lqTokenAmount).div(lqBNBAmount);
    _mintProfit[epoch] = tokenAmount;
    _totalSupply = _totalSupply.add(tokenAmount);
    mintAmount = mintAmount.add(tokenAmount);
    _gameBalances[profitHolderAddress] = _gameBalances[
       profitHolderAddress
    ].add(tokenAmount);
  }
}

```

##### Recommendation

The contract could not rely on an external factor in order to mutate its total supply. If
this is a business logic requirement, then it could sanitise the result of the external
call so it cannot dramatically affect the internal total supply.


-----

