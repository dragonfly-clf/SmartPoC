## QSP-24 Increased loss of precision due to dividing before multiplication

#### Severity: Informational

 Status: Acknowledged

###### File(s) affected: RariFundProxy.sol (in all repos), MStablePoolController.sol (rari-stable-pool-contracts and rari-yield-pool-contracts),
```
RariFundManager.sol (rari-stable-pool-contracts and rari-yield-pool-contracts), RariFundPriceConsumer.sol (rari-stable-pool-contracts and rariyield-pool-contracts) RariGovernanceTokenDistributor.sol (rari-goverance-contracts),

```

###### Description: To reduce the loss of precision caused by integer division, multiplication should always be performed before division. Several locations in the code were identified where this rule is
 not satisfied and hence a larger loss of precision is possible:

#### 1. In RariFundProxy.withdrawAndExchange the division in the following assignment uint256 outputAmount = 18 >= outputDecimals ? inputAmounts[i].div(10 **

```
(uint256(18).sub(outputDecimals))) : inputAmounts[i].mul(10 ** (outputDecimals.sub(18)));

```

#### is performed before the multiplication in this assignment

```
realOutputAmount = outputAmount.sub(outputAmount.mul(MStableExchangeController.getSwapFee()).div(1e18));

```

#### 2. In MStablePoolController.withdraw the division in the following assignment uint256 credits = amount.mul(1e18).div(exchangeRate); is performed before the
 division in the following if-condition if (credits.mul(exchangeRate).div(1e18) < amount)


#### 3. In RariFundManager.depositTo the division in the following assignment uint256 amountUsd =
```
  amount.mul(pricesInUsd[_currencyIndexes[currencyCode]]).div(10 ** _currencyDecimals[currencyCode]);

```

#### is performed before the multiplication in the


#### following assignment

```
rftAmount = amountUsd.mul(rftTotalSupply).div(fundBalanceUsd);

```

#### 4. In RariFundPriceConsumer.getMUsdUsdPrice the following assignment contains a division before the last multiplication usdSupplyScaled =
```
  usdSupplyScaled.add(bAssets[i].vaultBalance.mul(bAssets[i].ratio).div(1e8).mul(bAssetUsdPrices[i]));

 5. In RariGovernanceTokenDistributor.storeRgtDistributedPerRft the following assignment contains a division before the last multiplication
  _rgtPerRftAtLastSpeedUpdate[i_scope_0] =
  _rgtPerRftAtLastSpeedUpdate[i_scope_0].add(rgtToDistribute.mul(ethFundBalanceUsd).div(fundBalanceSum).mul(1e18).div(totalSupply))

 6. In RariGovernanceTokenDistributor.storeRgtDistributedPerRft the following assignment contains a division before the last multiplication
  _rgtPerRftAtLastSpeedUpdate[i_scope_0] =
  _rgtPerRftAtLastSpeedUpdate[i_scope_0].add(rgtToDistribute.mul(_fundBalancesCache[i_scope_0]).div(fundBalanceSum).mul(1e18).div(totalSupply))

##### 7. In RariGovernanceTokenDistributor.getRgtDistributedPerRft the following assignment contains a division before the last multiplication
  _rgtPerRftAtLastSpeedUpdate[uint8(pool)].add(rgtToDistribute.mul(ethFundBalanceUsd).div(fundBalanceSum).mul(1e18).div(totalSupply))

#### 8. In RariGovernanceTokenDistributor.getRgtDistributedPerRft the following assignment contains a division before the last multiplication
  _rgtPerRftAtLastSpeedUpdate[uint8(pool)].add(rgtToDistribute.mul(_fundBalancesCache[uint8(pool)]).div(fundBalanceSum).mul(1e18).div(totalSupply))

```

-----

##### 9. In RariGovernanceTokenDistributor.getRgtDistributedPerRft the following assignment contains a division before the last multiplication
```
  rgtPerRftByPool[i_scope_0] =
  _rgtPerRftAtLastSpeedUpdate[i_scope_0].add(rgtToDistribute.mul(ethFundBalanceUsd).div(fundBalanceSum).mul(1e18).div(totalSupply))

#### 10. In RariGovernanceTokenDistributor.getRgtDistributedPerRft the following assignment contains a division before the last multiplication
  rgtPerRftByPool[i_scope_0] =
  _rgtPerRftAtLastSpeedUpdate[i_scope_0].add(rgtToDistribute.mul(_fundBalancesCache[i_scope_0]).div(fundBalanceSum).mul(1e18).div(totalSupply))

```

###### Recommendation:


###### Move the division after the multiplication to reduce the loss of precision.


###### Update from dev team:


###### We will refactor our code so that multiplication is always be performed before division.


