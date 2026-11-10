#### BLC - Business Logic Concern

**Criticality** minor / informative

**Location** contract.sol#L965

**Status** Unresolved

##### Description

The ratio distribution has an accuracy problem. All integer division rounds down to
the nearest integer in solidity. As a result, residual fees are left to the contract.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L965|
|Status|Unresolved|


function distributeRewardBUSD(Fees memory fees) internal returns (bool) {

uint256 totalFee = fees.liquid + fees.marketing + fees.rewards + fees.team;
uint256 amountBUSDToFee = ERC20(BUSD_ADDRESS).balanceOf(address(this));
ERC20(BUSD_ADDRESS).transfer(LIQUID_ADDRESS, amountBUSDToFee * (fees.liquid *
**1e3 / totalFee) / 1e3);**

ERC20(BUSD_ADDRESS).transfer(MARKETING_ADDRESS, amountBUSDToFee *
**(fees.marketing * 1e3 / totalFee) / 1e3);**

ERC20(BUSD_ADDRESS).transfer(REWARDS_ADDRESS, amountBUSDToFee *
**(fees.rewards * 1e3 / totalFee) / 1e3);**

ERC20(BUSD_ADDRESS).transfer(TEAM_ADDRESS, amountBUSDToFee * (fees.team *
**1e3 / totalFee) / 1e3);**

return true;
}


##### Recommendation

The ratio distribution may produce accuracy issues. All integer division rounds down
to the nearest integer in Solidity. As a result, the remaining fees will remain in the
contract.


-----

