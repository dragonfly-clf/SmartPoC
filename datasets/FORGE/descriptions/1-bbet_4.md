#### STC - Succeeded Transfer Check

**Criticality** minor / informative

**Location** contract.sol#L965

**Status** Unresolved

##### Description

According to the ERC20 specification, the transfer methods should be checked if
the result is successful. Otherwise, the contract may wrongly assume that the
transfer has been established.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L965|
|Status|Unresolved|


function distributeRewardBUSD(Fees memory fees) internal returns (bool) {

uint256 totalFee = fees.liquid + fees.marketing + fees.rewards + fees.team;
uint256 amountBUSDToFee = ERC20(BUSD_ADDRESS).balanceOf(address(this));
ERC20(BUSD_ADDRESS).transfer(LIQUID_ADDRESS, amountBUSDToFee * (fees.liquid *
1e3 / totalFee) / 1e3);

ERC20(BUSD_ADDRESS).transfer(MARKETING_ADDRESS, amountBUSDToFee *
(fees.marketing * 1e3 / totalFee) / 1e3);

ERC20(BUSD_ADDRESS).transfer(REWARDS_ADDRESS, amountBUSDToFee *
(fees.rewards * 1e3 / totalFee) / 1e3);

ERC20(BUSD_ADDRESS).transfer(TEAM_ADDRESS, amountBUSDToFee * (fees.team * 1e3
/ totalFee) / 1e3);

return true;
}


##### Recommendation

The contract should check if the result of the transfer methods is successful.


-----

