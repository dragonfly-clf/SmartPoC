#### L13 - Divide before Multiply Operation

**Criticality** minor / informative

**Location** contract.sol#L965

**Status** Unresolved

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L965|
|Status|Unresolved|


ERC20(BUSD_ADDRESS).transfer(REWARDS_ADDRESS,amountBUSDToFee * (fees.rewards *
1e3 / totalFee) / 1e3)
ERC20(BUSD_ADDRESS).transfer(LIQUID_ADDRESS,amountBUSDToFee * (fees.liquid * 1e3 /
totalFee) / 1e3)
ERC20(BUSD_ADDRESS).transfer(MARKETING_ADDRESS,amountBUSDToFee * (fees.marketing

- 1e3 / totalFee) / 1e3)
ERC20(BUSD_ADDRESS).transfer(TEAM_ADDRESS,amountBUSDToFee * (fees.team * 1e3 /
totalFee) / 1e3)


##### Recommendation

The multiplications should be prior to the divisions.