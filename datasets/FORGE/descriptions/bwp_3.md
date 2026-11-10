#### TSBD - Total Supply Balances Diversion

**Criticality** critical

**Location** contract.sol#L1178

**Status** Unresolved

##### Description

According to the mintProfit requirements, the total supply is increased. Since the
total supply is increased then a contract’s address should receive the minted
tokens. The contract does not mint these tokens to any address. As a result, the
balances are diverse from the total supply.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1178|
|Status|Unresolved|

```
tokenAmount = BNBAmount.mul(lqTokenAmount).div(lqBNBAmount);
_mintProfit[epoch] = tokenAmount;
_totalSupply = _totalSupply.add(tokenAmount);
mintAmount = mintAmount.add(tokenAmount);
_gameBalances[profitHolderAddress] = _gameBalances[
  profitHolderAddress
].add(tokenAmount);

```

##### Recommendation

The contract should not diverse the balances with the total supply.


-----

